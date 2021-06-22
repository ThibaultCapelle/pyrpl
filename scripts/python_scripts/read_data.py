# -*- coding: utf-8 -*-
"""
Created on Mon Oct 19 15:11:11 2020

@author: QMPL
"""

import struct, mmap
while(True):
    with open('/dev/mem', 'w+') as f:
        mm=mmap.mmap(f.fileno(), 2**17, offset=0x40210000)
        j=0
        for i in range(2**14):
            if(mm[4*i:4*i+4]!=b'' and struct.unpack('L', mm[4*i:4*i+4])[0]!=0):
                j+=1
        print(j)
                