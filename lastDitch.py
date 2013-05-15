import numpy
import cc
import xfun

freq = 67e3
tankVoltages = [0]*5
phases = [0]*5
d = [0]
print "freq, voltage, phase"

while True:
	xfun.setFrequency(freq)
	phases.append(cc.getPhase(freq))
	tankVoltages.append(cc.getTankVoltage())
	tankVoltages.pop(0)
	d.append(abs(numpy.polyfit(range(len(tankVoltages)), tankVoltages, 1)[1]))
	if d[-1] > d[-2]:
		df = -abs(10*d[-1])
	if d[-1] < d[-2]:
		df = +abs(10*d[-1])
	df = int(numpy.sign(df)*min(abs(df), 100))
	print "changing frequency by", df, "Hz"
	freq += df
	print freq, tankVoltages[-1], phases[-1]
