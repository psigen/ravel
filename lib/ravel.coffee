# Do nothing yet.
console.log 'Loaded Ravel module.'

# Create some test code to load an XML file.
fs = require 'fs'
p2 = require 'p2'
{parseString} = require 'xml2js'

loadWorldStr = (str) ->
  world = new p2.World
  # Do nothing.

# Load a map from file.
fs.readFile __dirname + '/../config/map.svg', (err, data) ->
  if err?
    console.error "Error loading: " + err
    return

  # TODO: check if this had an error loading.
  parseString data, (err, result) ->
    if err?
        console.error "Error parsing: " + err
        return

    loadWorldStr(result)