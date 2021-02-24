#!/bin/bash

cat red_pitaya.bin > /dev/xdevcfg
python write_reg.py 0x40350000 0x0 7
python write_reg.py 0x40360000 0x0 14
python write_reg.py 0x40350000 0x4 1
python write_reg.py 0x40360000 0x4 2
python write_reg.py 0x40370000 0x108 1000000
python write_reg.py 0x40370000 0x110 1000
python write_reg.py 0x40370000 0x114 1000
python write_reg.py 0x40370000 0x0 8


