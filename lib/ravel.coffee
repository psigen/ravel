FileURL = require 'file-url'
FileAPI = require 'file-api'
WebGL = require './webgl_stub.coffee'
OIMO = require '../ext/Oimo.js'

# Load BabylonJS with faked browser elements.
# TODO: how do we do this without the scope issues?
global.FileReader = FileAPI.FileReader
global.File = FileAPI.File
global.OIMO = OIMO
global.XMLHttpRequest = require("xmlhttprequest").XMLHttpRequest;
BABYLON = require 'babylonjs'

# Load the BABYLON 3D engine.
console.log "Creating engine"
canvas = document.createElement "canvas"
engine = new BABYLON.Engine canvas, false

# Reference a scene from file.
#sceneUri = new FileAPI.File('./assets/Samples/Scenes/Mansion/Mansion.babylon')
sceneUri = new FileAPI.File('./assets/Samples/Scenes/hillvalley/HillValley.babylon')
rootUri = FileURL(__dirname)

# Define the mesh object update format.
meshUpdate = (mesh) ->
  id: mesh.id
  p: mesh.position.asArray()
  r: mesh.rotation.asArray()

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

  # Create an emitter that outputs updates for this level.
  scene.afterRender = ->    
    update = (meshUpdate(mesh) for mesh in scene.meshes)
    socket.emit id, update

  # Start the rendering loop.
  console.log "Starting rendering loop."
  engine.runRenderLoop ->
    scene.render()
