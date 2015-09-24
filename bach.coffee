brain = require 'brain'
fs = require 'fs'
readline = require 'readline'

vectors = []
prevVector = (null for [0...100])

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
	prevVector = (null for [0...100])
	for i in [1..100] by 1
		output = net.run(prevVector)
		defuzz(output)
		prevVector = output

train = ->
	net = new brain.NeuralNetwork()

	net.train vectors,
		errorThresh: 0.0085

	generate(net)


fileReader = readline.createInterface
  input: fs.createReadStream('numbers')
  terminal: false

fileReader.on 'line', (line) ->
	noteNumber = parseInt line, 10
	return if not noteNumber

	vector = (0 for [0...100])
	vector[noteNumber] = 1
	vectors.push
		input: prevVector
		output: vector
	prevVector = vector

fileReader.on 'close', train
