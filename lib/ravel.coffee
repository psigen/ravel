# Do nothing yet.
console.log 'Loaded Ravel module.'

FileURL = require 'file-url'
FileAPI = require 'file-api'
WebGL = require './webgl_stub.coffee'
OIMO = require '../ext/Oimo.js'

# Fake browser elements as necessary.
# Load BabylonJS with the faked browser elements.
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

  # Start the rendering loop.
  console.log "Starting rendering loop."
  engine.runRenderLoop ->
    scene.render()
