# Register Coffeescript.
require('coffee-script/register')
require('./lib/ravel.coffee')
{VM} = require 'vm2'
# NodeVM = require('vm2').NodeVM

# Create a safe (non-native) logging function to use inside the VM.
console_log = (args...) ->
    console.log(args...)

# Create a VM with access to console, but not native plugins.
vm = new VM
    timeout: 100,
    sandbox: {}

# Now we can use VM.run to execute stuff in the VM.
# vm.run "while(true) { log('hello') }"

express = require('express')
app = express()
http = require('http').Server(app)
io = require('socket.io')(http)

app.set 'views', __dirname + '/views'
app.set 'view engine', 'jade'
app.use express.static(__dirname + '/public')

app.get '/', (req, res) ->
  res.render 'index',
    title: 'RAVEL'
    message: 'hello-world'

io.on 'connection', (socket) ->
  console.log 'User connected.'

  sandbox =
    log: (args...) ->
        socket.emit 'output', '[LOG]   ' + args
    info: (args...) ->
        socket.emit 'output', '[INFO]  ' + args
    warn: (args...) ->
        socket.emit 'output', '[WARN]  ' + args
    error: (args...) ->
        socket.emit 'output', '[ERROR] ' + args

  socket.on 'disconnect', ->
    console.log 'User disconnected.'

  socket.on 'execute', (command) ->
    console.log 'Executing...'
    try
        vm.options.sandbox = sandbox
        vm.run command
    catch err
        console.error err
        socket.emit 'output', '[TRACE] ' + err

http.listen 3000, ->
  console.log 'listening on *:3000'
