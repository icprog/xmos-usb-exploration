import sys
from pylab import *
#d = np.loadtxt("freqRespCompensatedNew.txt").T
d = np.loadtxt(sys.argv[1]).T
ax1 = subplot(111)
title("Frequency Domain Characteristics")
xlabel("Drive Frequency")
ylabel("Tank Cap Voltage (RMS)")
plot(d[0], d[2], 'k')
ax2 = twinx()
ax2.yaxis.grid(color='gray', linestyle='dashed')
plot(d[0], d[1]+6, 'r')
ylabel("Phase Difference (degrees)")
show()
