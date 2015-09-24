brain = require 'brain'
fs = require 'fs'
readline = require 'readline'

defaultVector = ->
	(null for [0...100])

vectors = []
prevVector = defaultVector()

defuzz = (vector) ->
	vectorSum = vector.reduce (a, b) -> a + b
	rand = Math.random() * vectorSum
	cumulative = 0
	for interval, index in vector
		cumulative = cumulative + interval
		if rand < cumulative
			console.log index
			break

generate = (net) ->
	prevVector = defaultVector()
	for i in [1..100] by 1
		output = net.run(prevVector)
		defuzz(output)
		prevVector = output

train = ->
	net = new brain.NeuralNetwork()

	stat = net.train vectors,
		errorThresh: 0.0085

	console.warn(stat)
	generate(net)


fileReader = readline.createInterface
  input: fs.createReadStream('numbers')
  terminal: false

fileReader.on 'line', (line) ->
	noteNumber = parseInt line, 10
	return if not noteNumber

	vector = defaultVector()
	vector[noteNumber] = 1
	vectors.push
		input: prevVector
		output: vector
	prevVector = vector

fileReader.on 'close', train
