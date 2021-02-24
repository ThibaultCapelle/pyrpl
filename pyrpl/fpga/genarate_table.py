import numpy as np
import matplotlib.pylab as plt
LUTSZ = 11     #number of LUT entries
LUTBITS = 17   #LUT word size
def from_pyint(val, bits=17):
    """compute the 2's complement of int value val"""
    if val<0: # if sign bit is set e.g., 8bit: 128-255
        val = np.abs(val) - (1 << bits)        # compute negative value
        return "'b"+'{:017b}'.format(np.abs(val)&((1<<14)-1)+(1<<16)) +";\n"
    else:
        return "'b"+'{:017b}'.format(np.abs(val)&((1<<14)-1)) +";\n"
def from_pyintbis(val, bits=17):
    """compute the 2's complement of int value val"""
    if val<0:
        return "-"+str(LUTBITS-1)+"'d"+'{:}'.format(np.abs(val)) +";\n"
    else:
        return str(LUTBITS-1)+"'d"+'{:}'.format(np.abs(val)) +";\n"
data = np.zeros(2**LUTSZ,dtype=np.long)
for i in range(len(data)):
    data[i] = np.long(np.round((2**(LUTBITS-1)-1)*np.sin(((float(i)+0.5)/len(data))*2*np.pi)))
#data = [from_pyint(v,bitlength=LUTBITS) for v in data]
plt.plot(data)

with open('table.txt', 'w') as f:
    f.write("reg [LUTBITS-1:0] lutrom [0:(1<<LUTSZ)-1];\n")
    f.write("\n")
    f.write("initial begin\n")
    for i in range(len(data)):
        string = "   lutrom["+str(i)+"] = "+str(LUTBITS)+from_pyint(data[i])
        f.write(string)
    f.write("end\n")
