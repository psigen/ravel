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

  update: =>
    # Step physics forward and send out update.
    if @scene?
      @scene.render()

    # Re-execute object scripts as necessary.
    @vm # TODO: DO STUFF

module.exports = World