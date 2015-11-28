FileAPI = require 'file-api'
WebGL = require './webgl_stub.coffee'
OIMO = require '../ext/Oimo.js'
UUID = require 'node-uuid'
{VM} = require 'vm2'

# Load BabylonJS with faked browser elements.
# TODO: how do we do this without the scope issues?
global.FileReader = FileAPI.FileReader
global.File = FileAPI.File
global.OIMO = OIMO
global.XMLHttpRequest = require("xmlhttprequest").XMLHttpRequest;
BABYLON = require 'babylonjs'

# Load the BABYLON 3D engine.
canvas = document.createElement "canvas"
engine = new BABYLON.Engine canvas, false

# Define a class representing a player world.
class World
  constructor: (io, uri) ->
    # Create a unique ID for this scene.
    # TODO: make this unique
    self = @
    self.id = 'update'

    # Reference a scene from file.
    sceneUri = new FileAPI.File './public/' + uri
    rootUri = "file://"

    # Load the scene using BABYLON.
    BABYLON.SceneLoader.Load rootUri, sceneUri, engine, (scene) ->
      console.log "Loaded: " + sceneUri.path

      # Enable physics using default plugin (Oimo)
      if not scene.enablePhysics new BABYLON.Vector3(0, 0, -10)
        console.error "Unable to initialize physics."

      # Disable every engine option.
      scene.audioEnabled = false
      scene.fogEnabled = false
      scene.lensFlaresEnabled = false
      scene.lightsEnabled = false
      scene.particlesEnabled = false
      scene.postProcessesEnabled = false
      scene.proceduralTexturesEnabled = false
      scene.renderTargetsEnabled = false
      scene.shadowsEnabled = false
      scene.spritesEnabled = false
      scene.texturesEnabled = false
      scene.useDelayedTextureLoading = false

      # Create an emitter that outputs updates for this scene.
      scene.afterRender = ->
        updates = []
        for mesh in scene.meshes
          updates.push
            id: mesh.id
            p: mesh.position.asArray()
            r: mesh.rotation.asArray()
        io.emit self.id, updates

      # Add the scene as an accessible member.
      self.scene = scene

    @vm = new VM
      timeout: 100,
      sandbox: {}

  execute: (socket, command) =>
    sandbox =
      log: (args...) ->
        socket.emit 'output', '[LOG]   ' + args
      info: (args...) ->
        socket.emit 'output', '[INFO]  ' + args
      warn: (args...) ->
        socket.emit 'output', '[WARN]  ' + args
      error: (args...) ->
        socket.emit 'output', '[ERROR] ' + args

      teleport: (name, x, y, z) =>
        mesh = @scene.getMeshByName(name)
        if mesh?
          mesh.position.addInPlace new BABYLON.Vector3(x, y, z)
          socket.emit 'output', 'TELEPORT SUCCESS: ' + name
        else
          socket.emit 'output', 'TELEPORT FAILED: ' + name

    console.log 'Executing: ', command
    try
        @vm.options.sandbox = sandbox
        @vm.run command
    catch err
        console.error err
        socket.emit 'output', '[TRACE] ' + err

  update: =>
    # Step physics forward and send out update.
    if @scene?
      @scene.render()

      #mesh = @scene.getMeshByName 'courthouse'
      #mesh.translate new BABYLON.Vector3(0.0, 0.0, 1.0), 0.2, BABYLON.Space.WORLD

    # Re-execute object scripts as necessary.
    @vm # TODO: DO STUFF

module.exports = World