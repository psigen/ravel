# Register Coffeescript.
require 'coffee-script/register'
Ravel = require './lib/ravel.coffee'
World = require './lib/world.coffee'
repl = require('repl')

# Set server update rate.
fps = 30
sceneUri = ['./assets/Samples/Scenes/Flat2009/', 'Flat2009.babylon']

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

# Create a world.
world = new World io, sceneUri[0], sceneUri[1]
setInterval world.update, 1000 / fps

io.on 'connection', (socket) ->
  console.log 'User connected.'
  world.initialize socket

  socket.on 'disconnect', ->
    console.log 'User disconnected.'

http.listen 3000, ->
  console.log 'listening on *:3000'

# Start command line console.
repl.start('> ').context.world = world
