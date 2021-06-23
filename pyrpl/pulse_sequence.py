# -*- coding: utf-8 -*-
"""
Created on Fri Oct  9 17:46:43 2020

@author: QMPL
"""

import time
import numpy as np
import struct, mmap
import sys
from ServerPy.server_base import Generic_Server
from ServerPy.client_base import Generic_Client

class Pin:
    
    def __init__(self, pin):
        self.pin=int(pin)
        self.set_direction(1)
    
    def set_direction(self, val):
        with open('/dev/mem', 'w+') as f:
            mm=mmap.mmap(f.fileno(), 4096, offset=0x40000000)
            mm[16:20]=struct.pack('I', int(val<<self.pin))

    def set_state(self, val):
        with open('/dev/mem', 'w+') as f:
            mm=mmap.mmap(f.fileno(), 4096, offset=0x40000000)
            mm[24:28]=struct.pack('I', int(val<<self.pin))

class Server(Generic_Server):
    
    def __init__(self, ip='172.24.3.104', port=9000):
        super().__init__(ip=ip, port=port, serial_driver=Driver())

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

class Client(Generic_Client):
    
    def __init__(self, ip='172.24.3.104', port=9000):
        super().__init__(ip=ip, port=port)
    
    def write_reg(self, adress_base=None, offset=None, bitmask=None, val=None):
        if val is None:
            return self.ask(self.parse('write_reg()', adress_base=adress_base,
                                offset=offset, bitmask=bitmask, val=val))
        else:
            self.send(self.parse('write_reg()', adress_base=adress_base,
                                offset=offset, bitmask=bitmask, val=val))
    
    def set_continuous_waveform(self,  waveform=None, duration=None,
                                frequency=None):
        self.send(self.parse('set_continuous_waveform()', waveform=waveform,
                             duration=duration, frequency=frequency))
    
    def trigger(self):
        self.send(self.parse('trigger()'))
    
    def set_asg(self, val, channel):
        self.send(self.parse('set_asg()', on=val, channel=channel))
    
    def set_number_of_burst(self, val):
        self.send(self.parse('set_number_of_burst()', val=val))
    
    def set_waveform(self, data):
        self.send(self.parse('set_waveform()', data=data))
    
    def prepare_pulse(self, waveform, duration):
        self.send(self.parse('prepare_pulse()', 
                             waveform=waveform, 
                             duration=duration))

class Driver:
    
    def __init__(self):
        #self.pin=Pin(0)
        #self.pin.set_state(0)
        self.initialize()
    
    def initialize(self):
        self.write_reg(0x40200000, 0x0, bitmask=0xffff, val=17)
        self.write_reg(0x40200000, 0x0, bitmask=0xffff0000, val=17)
        self.write_reg(0x40200000, 0x4, val=0x2000)
        self.write_reg(0x40200000, 0x24, val=0x2000)
        self.write_reg(0x40200000, 0x10, val=0x100)
        self.write_reg(0x40200000, 0x30, val=0x100)
        self.write_reg(0x40380000, 0x4, val=1)
        self.write_reg(0x40390000, 0x4, val=2)
        '''self.write_reg(0x40350000, 0x0, val=7)
        self.write_reg(0x40360000, 0x0, val=14)
        self.write_reg(0x40350000, 0x4, val=2)
        self.write_reg(0x40360000, 0x4, val=1)
        self.write_reg(0x40370000, 0x0, val=8)
        self.write_reg(0x40370000, 0x4, val=0)
        self.write_reg(0x40370000, 0x114, val=1000)
        self.write_reg(0x40370000, 0x110, val=1000)
        self.write_reg(0x40370000, 0x108, val=1000000)'''
            
    def write_reg(self, adress_base=None, offset=None, bitmask=None, val=None):
        if bitmask is None:
            bitmask=0xFFFFFFFF
        strbit='{:b}'.format(bitmask)
        bitmask_offset=0
        while(strbit[-bitmask_offset-1]=='0'):
            bitmask_offset+=1
        with open('/dev/mem', 'w+') as f:
            mm=mmap.mmap(f.fileno(), 4096, offset=adress_base)
            if val is None:
                mm=mm[offset:offset+4]
                res=struct.unpack('<L', mm)[0]
                return (res & bitmask)>>bitmask_offset
            else:
                val = int(val) << bitmask_offset
                res=struct.unpack('<L', mm[offset:offset+4])[0]
                new = res & (~bitmask) | (int(val) & bitmask)
                mm[offset:offset+4]=struct.pack('<L', new)
    
    def trigger(self, pulse_id=None):
        self.pin.set_state(1)
        self.pin.set_state(0)
    
    def set_frequency(self, val=None):
        FPGA_val=int(val/125e6*(2**32))
        self.write_reg(0x40370000, 0x108, val=FPGA_val)
        
    def format_waveform_data(self, data):
        data = np.array(np.round((2 ** 13 - 1) * np.array(data)), dtype=np.int32)
        data[data >= 2 ** 13] = 2 ** 13 - 1
        data[data < 0] += 2 ** 14
        # values that are still negative are set to maximally negative
        data[data < 0] = -2 ** 13
        return np.array(data, dtype=np.uint32)
    
    def set_waveform(self, data=None, channel=None):
        if channel is None:
            channel=1
        if channel==1:
            with open('/dev/mem', 'w+') as f:
                mm=mmap.mmap(f.fileno(), 2**17, offset=0x40210000)
                for i, dat in enumerate(data):
                    mm[i*4:i*4+4]=struct.pack('<L',dat)
        elif channel==2:
            with open('/dev/mem', 'w+') as f:
                mm=mmap.mmap(f.fileno(), 2**17, offset=0x40220000)
                for i, dat in enumerate(data):
                    mm[i*4:i*4+4]=struct.pack('<L',dat)
    
    def set_continuous_waveform(self, waveform=None, duration=None,
                                frequency=None):
        self.set_asg(0, channel=1)
        self.set_asg(1, channel=1)
        self.set_asg(0, channel=2)
        self.set_asg(1, channel=2)
        self.set_asg_frequency(frequency, channel=2)
        #self.synchronize_phases()
        self.set_asg_frequency(1./duration, channel=1)
        self.set_waveform(self.format_waveform_data(waveform), channel=1)
        self.set_waveform(self.format_waveform_data(np.sin(np.linspace(0,2*np.pi,16384))),
                          channel=2)
        self.set_trigger_source('imm', chan=1)
        self.set_trigger_source('imm', chan=2)
        self.set_number_of_burst(0, channel=1)
        self.set_number_of_burst(0, channel=2)
        
    def set_trigger_source(self, source='ext', chan=1):
        if chan==1:
            bitmask=0x0007
        elif chan==2:
            bitmask=0x70000
        if source=='ext':
            source=2
        elif source=='imm':
            source=1
        self.write_reg(0x40200000, 0x0, bitmask=bitmask, val=source)
    
    def set_asg_frequency(self, val=None, channel=None):
        if channel is None:
            channel=1
        FPGA_val=int(val/125e6*(2**30))
        if channel==1:
            self.write_reg(0x40200000, 0x10, val=FPGA_val)
        elif channel==2:
            self.write_reg(0x40200000, 0x30, val=FPGA_val)
    
    def set_asg(self, on=None, channel=None):
        if channel is None:
            channel=1
        if channel==1:
            self.write_reg(0x40200000, 0x0, bitmask=0x40, val=~int(on))
        elif channel==2:
            self.write_reg(0x40200000, 0x0, bitmask=0x400000, val=~int(on))
        
    def pulse_end(self, pulse_id=None, connection=None):
        return str(pulse_id)+'_end'
    
    def set_number_of_burst(self, val=None, channel=None):
        if channel is None:
            channel=1
        if channel==1:
            self.write_reg(0x40200000, 0x18, val=val)
        elif channel==2:
            self.write_reg(0x40200000, 0x38, val=val)
    
    def set_phase_offset(self, val=None):
        FPGA_VAL = int(val/np.pi*(1<<31))
        self.write_reg(0x40370000, 0x104, val=FPGA_VAL)
    
    def prepare_pulse(self, frequency=None, waveform=None, duration=None,
                      ext_trig=True):
        self.set_asg(0)
        self.set_asg(1)
        #self.set_frequency(frequency)
        #self.synchronize_phases()
        self.set_asg_frequency(1./duration)
        
        self.set_waveform(self.format_waveform_data(waveform))
        if ext_trig:
            self.set_trigger_source('ext')
            self.set_number_of_burst(1)
        else:
            self.set_trigger_source('imm')
            self.set_number_of_burst(0)
    
    def pulse_seq(self, durations=None, frequencies=None,
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
                            Delayed_callback(self.trigger, np.sum(durations[:i])+delay)]
            elif len(waveform)==1 and waveform[0]==0:
                pass
                '''callbacks.append(Delayed_callback(self.pulse_end, np.sum(durations[:i+1])+delay,
                                               kwargs=dict({'pulse_id':i+1})))'''
       
        t_ini=time.time()
        for callback in callbacks:
            callback.start(t_ini)
        while len(callbacks)>0:
            for callback in callbacks:
                if callback.check():
                    callbacks.remove(callback)
        
            
        
if __name__=='__main__':
    if len(sys.argv)>1:
        if sys.argv[1]=='server':
            s=Server()
        elif sys.argv[1]=='client':
            s=Client()
    else:
        s=Client()
