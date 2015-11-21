VM = require('vm2').VM
# NodeVM = require('vm2').NodeVM

# Create a safe (non-native) logging function to use inside the VM.
console_log = (args...) ->
    console.log(args...)

# Create a VM with access to console, but not native plugins.
vm = new VM
    timeout: 100,
    sandbox: { "log": console_log }

# Now we can use VM.run to execute stuff in the VM.
# vm.run "while(true) { log('hello') }"

express = require('express')
app = express()
http = require('http').Server(app)

app.set 'views', __dirname + '/views'
app.set 'view engine', 'jade'
app.use express.static(__dirname + '/public')

app.get '/', (req, res) ->
  res.render 'index',
    title: 'RAVEL'
    message: 'hello-world'

http.listen 3000, ->
  console.log 'listening on *:3000'
