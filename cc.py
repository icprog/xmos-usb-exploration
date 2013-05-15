import numpy
import xfun
import tds3014b
import time

tds = tds3014b.tds3014b("10.42.0.86")

getTankVoltage = lambda: tds.get_measurement(3, True)

def proportionalLoopVoltage():
	freq = 60e3
	phaseErrorLast = -90
	tankVoltageLast = 0
	sign = -1
	while True:
		xfun.setFrequency(freq)
		phaseError = getPhase()
		tankVoltage = getTankVoltage()
		if tankVoltage > tankVoltageLast:
			sign = -1
		if tankVoltage < tankVoltageLast:
			sign = +1
		df = sign*min(1000*abs(tankVoltageLast-tankVoltage)/tankVoltage, 1000)
		print "change in frequency of ", df
		freq += df
		time.sleep(1)
		phaseErrorLast = phaseError
		tankVoltageLast = tankVoltage
		print freq, phaseError, tankVoltage

def freqSweep():
	for freq in numpy.linspace(72e3, 60e3, 50):
		xfun.setFrequency(freq)
		time.sleep(.05)
		print freq, getPhase(freq), getTankVoltage()

def fitSine(tList, yList, freq):
	# least squares sine wave fitter adapted from http://exnumerus.blogspot.com/2010/04/how-to-fit-sine-wave-example-in-python.html
	# oscilloscope phase measurement is unreliable
	# simpler approaches (comparator / xor) don't cope well with noisy (real) data
	b = numpy.matrix(yList).T
	rows = [ [numpy.sin(freq*2*numpy.pi*t), numpy.cos(freq*2*numpy.pi*t), 1] for t in tList]
	A = numpy.matrix(rows)
	(w,residuals,rank,sing_vals) = numpy.linalg.lstsq(A,b)
	phase = numpy.arctan2(w[1,0],w[0,0])*180/numpy.pi
	amplitude = numpy.linalg.norm([w[0,0],w[1,0]],2)
	bias = w[2,0]
	return (phase,amplitude,bias)

def getWaveforms():
	h1, d1 = tds.get_waveform(1)
	h2, d2 = tds.get_waveform(2)
	t = numpy.arange(float(h1['NR_PT']))*float(h1['XINCR'])
	return t, d1, d2

def getPhase(freq):
	ct = 3
	results = []
	for i in range(ct):
		t, d1, d2 = getWaveforms()
		p1, a1, b1 = fitSine(t, d1, freq)
		p2, a2, b2 = fitSine(t, d2, freq)
		results.append(p1 - p2)
	stddev = numpy.std(results)
	preliminaryMean = numpy.mean(results)
	clean = []
	for result in results:
		if numpy.abs(result-preliminaryMean) < stddev:
			clean.append(result)
	result = numpy.sum(clean)/len(clean)
	return result

def pll():
	phase = []
	amplitude = []
	freq = 67e3
	setPoint = 0
	xfun.setFrequency(freq)
	phase.append(getPhase(freq))
	amplitude.append(getTankVoltage)
	while True:
		phase.append(getPhase(freq))
		amplitude.append(getTankVoltage)
		dFreq = -phase[-1]*100
		if abs(phase[-1]) < abs(phase[-2]):
			print "phase decreasing", phase[-1]
		else:
			print "phase increasing", phase[-1]
		freq += dFreq
		xfun.setFrequency(freq)
		time.sleep(.1)
		
if __name__ == "__main__":
	freqSweep()
