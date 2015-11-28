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

# Create a test scene.
###
createScene = ->
  scene = new BABYLON.Scene engine
  scene.clearColor = new BABYLON.Color3(0, 1, 0);

  camera = new BABYLON.FreeCamera("camera1", new BABYLON.Vector3(0, 5, -10), scene);
  camera.setTarget(BABYLON.Vector3.Zero());
  camera.attachControl(canvas, false);

  light = new BABYLON.HemisphericLight("light1", new BABYLON.Vector3(0, 1, 0), scene);
  light.intensity = .5;

  sphere = BABYLON.Mesh.CreateSphere("sphere1", 16, 2, scene);
  sphere.position.y = 1;

  ground = BABYLON.Mesh.CreateGround("ground1", 6, 6, 2, scene);
  return scene;

scene = createScene();
###

sceneUri = new FileAPI.File('../assets/Samples/Scenes/Mansion/Mansion.babylon')
rootUri = FileURL(__dirname)

BABYLON.SceneLoader.Load rootUri, sceneUri, engine, (scene) ->
  console.log "Loaded: " + sceneUri.path

  if not scene.enablePhysics new BABYLON.Vector3(0, 0, -10)
    console.error "Unable to initialize physics."

  # Start the rendering loop.
  engine.runRenderLoop ->
    console.log scene.getPhysicsEngine()
    scene.render()
