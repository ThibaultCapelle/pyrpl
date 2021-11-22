<<<<<<< HEAD
# -*- coding: utf-8 -*-
"""
Created on Fri Oct  9 17:46:43 2020

@author: QMPL
"""

import struct, mmap
import sys
from ServerPy.server_base import Generic_Server
from ServerPy.client_base import Generic_Client
import socket
h_name = socket.gethostname()
IP_addres = socket.gethostbyname(h_name+'.local')


class Server(Generic_Server):
    
    def __init__(self, ip=IP_addres, port=9000):
        super().__init__(ip=ip, port=port, serial_driver=Driver())

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
    
    @property
    def trigger_delay(self):
        return self.write_reg(0x40200000, 0x240)/125e6
    
    @trigger_delay.setter
    def trigger_delay(self, val):
        FPGA_val=int(val*125e6)
        self.write_reg(0x40200000, 0x240, val=FPGA_val)
        
    @property
    def TTL_frequency(self):
        return 125e6/9/self.write_reg(0x40200000, 0x248)
    
    @TTL_frequency.setter
    def TTL_frequency(self, val):
        FPGA_val=int(125e6/9/val)
        self.write_reg(0x40200000, 0x248, val=FPGA_val)

class Driver:
    
    def __init__(self):
        pass
            
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
        
            
        
if __name__=='__main__':
    if len(sys.argv)>1:
        if sys.argv[1]=='server':
            if len(sys.argv)==2:
                s=Server()
        elif sys.argv[1]=='client':
            s=Client()
    else:
        s=Client()
=======
# -*- coding: utf-8 -*-
"""
Created on Fri Oct  9 17:46:43 2020

@author: QMPL
"""

import struct, mmap
import sys
from ServerPy.server_base import Generic_Server
from ServerPy.client_base import Generic_Client
import socket
h_name = socket.gethostname()
IP_addres = socket.gethostbyname(h_name+'.local')


class Server(Generic_Server):
    
    def __init__(self, ip=IP_addres, port=9000):
        super().__init__(ip=ip, port=port, serial_driver=Driver())

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
    
    @property
    def trigger_delay(self):
        return self.write_reg(0x40200000, 0x240)/125e6
    
    @trigger_delay.setter
    def trigger_delay(self, val):
        FPGA_val=int(val*125e6)
        self.write_reg(0x40200000, 0x240, val=FPGA_val)
        
    @property
    def TTL_frequency(self):
        return 125e6/9/self.write_reg(0x40200000, 0x248)
    
    @TTL_frequency.setter
    def TTL_frequency(self, val):
        FPGA_val=int(125e6/9/val)
        self.write_reg(0x40200000, 0x248, val=FPGA_val)

class Driver:
    
    def __init__(self):
        pass
            
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
        
            
        
if __name__=='__main__':
    if len(sys.argv)>1:
        if sys.argv[1]=='server':
            if len(sys.argv)==2:
                s=Server()
        elif sys.argv[1]=='client':
            s=Client()
    else:
        s=Client()
>>>>>>> 056b055eef32a5a103acd24647a7177bcbf6dbec
