brain = require 'brain'
fs = require 'fs'
readline = require 'readline'

vectors = []

class History
  constructor: (size) ->
    @size = size || 4

  vectorize: ->
    # concat all entries
    [].concat.apply([], @_history())

  push: (vector) ->
    @_history().unshift vector
    @_history().pop()
    vector

  _history: ->
    @__history ||= (@_defaultVector() for [0..@size])

  _defaultVector: ->
    (null for [0...100])

defuzz = (vector) ->
  vectorSum = vector.reduce (a, b) -> a + b
  rand = Math.random() * vectorSum
  cumulative = 0
  defuzzed = (0 for [0...100])

  for interval, index in vector
    cumulative = cumulative + interval
    if rand < cumulative
      console.log index
      defuzzed[index] = 1
      break

  defuzzed

generate = (net) ->
  genHist = new History()
  for i in [1..100] by 1
    output = net.run(genHist.vectorize())
    defuzzed = defuzz(output)
    genHist.push(defuzzed)

train = ->
  net = new brain.NeuralNetwork()

  stat = net.train vectors,
    errorThresh: 0.005

  console.warn stat
  generate(net)


trainHist = new History()

fileReader = readline.createInterface
  input: fs.createReadStream('numbers')
  terminal: false

fileReader.on 'line', (line) ->
  noteNumber = parseInt line, 10
  return if not noteNumber

  vector = (0 for [0...100])
  vector[noteNumber] = 1

  vectors.push
    input: trainHist.vectorize()
    output: vector

  trainHist.push(vector)

fileReader.on 'close', train
