# -*- coding: utf-8 -*-
"""
Created on Thu Oct 15 08:48:18 2020

@author: QMPL
"""

import struct, mmap, sys

if __name__=='__main__':
    if len(sys.argv)==3:
        file,offset,bit=sys.argv
        with open('/dev/mem', 'w+') as f:
            mm=mmap.mmap(f.fileno(), 4096, offset=int(offset, 16))
            res=mm[int(bit, 16):int(bit, 16)+4]
            print(struct.unpack('<L', res))
    elif len(sys.argv)==4:
        file,offset,bit,val=sys.argv
        with open('/dev/mem', 'w+') as f:
            mm=mmap.mmap(f.fileno(), 4096, offset=int(offset, 16))
            mm[int(bit, 16):int(bit, 16)+4]=struct.pack('<L', int(val))