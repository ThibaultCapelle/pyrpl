# -*- coding: utf-8 -*-
"""
Created on Fri Oct  9 17:46:43 2020

@author: QMPL
"""

import socket, json, time
import numpy as np
import struct, mmap

class Pin:
    
    def __init__(self, pin):
        self.pin=int(pin)

    def set_state(self, val):
        with open('/dev/mem', 'w+') as f:
            mm=mmap.mmap(f.fileno(), 4096, offset=0x40000000)
            mm[24:28]=struct.pack('I', int(val<<self.pin))

class Server:
    
    def __init__(self, ip='172.24.3.104', port=9000):
        self.ip=ip
        self.port=port
        self.pin=Pin(0)
        self.pin.set_state(0)
        self.interprete=Interprete(self)
        self.s=socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        try:
            self.s.bind((self.ip, self.port))
            self.s.listen(10)
            self.connected=True
            while self.connected:
                conn, addr=self.s.accept()
                raw_msglen = conn.recv(10)
                if not raw_msglen:
                    print("No raw_msglen")
                    break
                msglen = int(raw_msglen.decode(),16)
                print('len of packet is {:}'.format(msglen))
                data=self.receive_all(conn, msglen)
                if data is not None:
                    self.interpreter(conn, data)
                elif len(data)!=msglen:
                    print('the length and the data did not match')
        finally:
            self.s.close()
    
    def receive_all(self, sock, n):
        data = bytearray()
        i=1
        while len(data) < n:
            print('packet number {:}'.format(i))
            packet = sock.recv(n - len(data))
            if not packet:
                return None
            data.extend(packet)
            i+=1
        return data.decode()
    
    def send_answer(self, conn, message):
        message=json.dumps(dict({'content':message}))
        conn.sendall(('{:010x}'.format(len(message))+message).encode())
    
    def send_short_answer(self, conn, message):
        conn.sendall(message.encode())
    
    def interpreter(self, conn, message):
        cmd = json.loads(message)
        cmd['kwargs']['connection']=conn
        self.interprete.call(cmd)

class Delayed_callback:
    
    def __init__(self, method, delay, kwargs=dict()):
        self.method=method
        self.kwargs=kwargs
        self.delay=delay
    
    def start(self, t_ini):
        self.target_time=t_ini+self.delay
        
    def check(self):
        if time.time()>self.target_time:
            self.method(**self.kwargs)
            return True
        else:
            return False


class Interprete:
    
    def __init__(self, server):
        self.server=server
    
    def call(self, cmd):
        if len(cmd['args'])==0 or\
        (len(cmd['args'])==1 and len(cmd['args'][0])==0)or\
        'args' not in cmd.keys():
            getattr(self, cmd['command'])(**cmd['kwargs'])
        else:
            getattr(self, cmd['command'])(*cmd['args'], **cmd['kwargs'])  
    
    def trigger(self, pulse_id=None, connection=None):
        self.server.pin.set_state(1)
        self.server.pin.set_state(0)
        #self.server.send_answer(connection, str(pulse_id))
    
    def set_frequency(self, frequency):
        FPGA_val=int(frequency/125e6*(2**32))
        with open('/dev/mem', 'w+') as f:
            mm=mmap.mmap(f.fileno(), 4096, offset=0x40370000)
            mm[0x108:0x108+4]=struct.pack('I', FPGA_val)
        with open('/dev/mem', 'w+') as f:
            mm=mmap.mmap(f.fileno(), 4096, offset=0x40350000)
            mm[0x108:0x108+4]=struct.pack('I', FPGA_val)
    
    def synchronize_phases(self):
        with open('/dev/mem', 'w+') as f:
            mm=mmap.mmap(f.fileno(), 4096, offset=0x40370000)
            mm[0x100:0x100+4]=struct.pack('I', 0)
            mm[0x100:0x100+4]=struct.pack('I', 1)
        with open('/dev/mem', 'w+') as f:
            mm=mmap.mmap(f.fileno(), 4096, offset=0x40350000)
            mm[0x100:0x100+4]=struct.pack('I', 0)
            mm[0x100:0x100+4]=struct.pack('I', 1)
    
    def format_waveform_data(self, data):
        data = np.array(np.round((2 ** 13 - 1) * np.array(data)), dtype=np.int32)
        data[data >= 2 ** 13] = 2 ** 13 - 1
        data[data < 0] += 2 ** 14
        # values that are still negative are set to maximally negative
        data[data < 0] = -2 ** 13
        return np.array(data, dtype=np.uint32)
    
    def set_waveform(self, data):
        with open('/dev/mem', 'w+') as f:
            mm=mmap.mmap(f.fileno(), 2**17, offset=0x40210000)
            for i, dat in enumerate(data):
                mm[i*4:i*4+4]=struct.pack('<L',dat)
    
    def set_trigger_source(self, source):
        bitmask=0x0007
        if source=='ext':
            source=2
        with open('/dev/mem', 'w+') as f:
            mm=mmap.mmap(f.fileno(), 4096, offset=0x40210000)
            res=struct.unpack('<L', mm[:4])[0]
            new = res & (~bitmask) | (source & bitmask)
            mm[:4]=struct.pack('<L', new)
    
    def set_asg_frequency(self, val=None):
        FPGA_val=int(val/125e6*(2**30))
        with open('/dev/mem', 'w+') as f:
            mm=mmap.mmap(f.fileno(), 4096, offset=0x40200000)
            mm[0x10:0x10+4]=struct.pack('<L', FPGA_val)
        
    def pulse_end(self, pulse_id=None, connection=None):
        self.server.send_answer(connection, str(pulse_id)+'_end')
    
    def prepare_pulse(self, frequency=None, waveform=None, duration=None):
        t_ini=time.time()
        self.set_frequency(frequency)
        #self.synchronize_phases()
        self.set_asg_frequency(1./duration)
        self.set_trigger_source('ext')
        self.set_waveform(waveform)
        print(time.time()-t_ini)
    
    def pulse_seq(self, durations=None, connection=None, frequencies=None,
                  waveforms=None, delay=0.25):
        print(delay)
        callbacks=[]
        waveforms=[self.format_waveform_data(waveform) for waveform in waveforms]
        for i, waveform in enumerate(waveforms):
            if len(waveform)==16384:
                callbacks+=[Delayed_callback(self.prepare_pulse, np.sum(durations[:i]),
                                             kwargs=dict({'frequency':frequencies[i],
                                                          'duration':durations[i],
                                                          'waveform':waveforms[i]})),
                            Delayed_callback(self.trigger, np.sum(durations[:i])+delay),
                            Delayed_callback(self.pulse_end, np.sum(durations[:i+1])+delay,
                                               kwargs=dict({'connection':connection,
                                                     'pulse_id':i+1}))]
            elif len(waveform)==1 and waveform[0]==0:
                callbacks.append(Delayed_callback(self.pulse_end, np.sum(durations[:i+1])+delay,
                                               kwargs=dict({'connection':connection,
                                                     'pulse_id':i+1})))
       
        t_ini=time.time()
        for callback in callbacks:
            callback.start(t_ini)
        while len(callbacks)>0:
            for callback in callbacks:
                if callback.check():
                    callbacks.remove(callback)
        
            
        
if __name__=='__main__':
    s=Server()
