# Register Coffeescript.
require 'coffee-script/register'
RAVEL = require './lib/ravel.coffee'
WORLD = require './lib/world.coffee'

# Set server update rate.
fps = 30
sceneUri = './assets/Samples/Scenes/Flat2009/Flat2009.babylon'

# Create a safe (non-native) logging function to use inside the VM.
console_log = (args...) ->
    console.log(args...)

# Start a web server with Socket.IO.
express = require('express')
app = express()
http = require('http').Server(app)
io = require('socket.io')(http)

app.set 'views', __dirname + '/views'
app.set 'view engine', 'jade'
app.use express.static(__dirname + '/public')

app.get '/', (req, res) ->
  res.render 'babylon',
    title: 'RAVEL'
    message: 'hello-world'
    scene: sceneUri

# Create a world.
world = new WORLD io, sceneUri
setInterval world.update, 1000 / fps

io.on 'connection', (socket) ->
  console.log 'User connected.'

  socket.on 'disconnect', ->
    console.log 'User disconnected.'

  socket.on 'execute', (command) ->
    world.execute(socket, command)

http.listen 3000, ->
  console.log 'listening on *:3000'
