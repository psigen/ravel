VM = require('vm2').VM
# NodeVM = require('vm2').NodeVM

# Create a safe (non-native) logging function to use inside the VM.
console_log = (args...) ->
    console.log(args...)

# Create a VM with access to console, but not native plugins.
vm = new VM
    console: 'redirect',
    timeout: 100,
    sandbox: { "log": console_log }

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

  vm.on 'console.log', (args...) ->
    socket.emit 'output', '[LOG]   ' + args
  vm.on 'console.info', (args...) ->
    socket.emit 'output', '[INFO]  ' + args
  vm.on 'console.warn', (args...) ->
    socket.emit 'output', '[WARN]  ' + args
  vm.on 'console.error', (args...) ->
    socket.emit 'output', '[ERROR] ' + args
  vm.on 'console.dir', (args...) ->
    socket.emit 'output', '[DIR]   ' + args
  vm.on 'console.trace', (args...) ->
    socket.emit 'output', '[TRACE] ' + args

  socket.on 'disconnect', ->
    console.log 'User disconnected.'

  socket.on 'execute', (command) ->
    console.log 'Executing...'
    try
        vm.run command
    catch err
        console.error err
        socket.emit 'output', '[TRACE] ' + err

http.listen 3000, ->
  console.log 'listening on *:3000'
