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

# Perform munging to make local scene URIs work.
# TODO: What the hell is going on in here?
mungeUri = (rootUri, sceneUri) ->
  rootUri: "http://localhost:3000/" + rootUri
  sceneUri: sceneUri

# Define a class representing a player world.
class World
  constructor: (io, @rootUri, @sceneUri) ->
    # Create a unique ID to represent this world.
    @id = UUID.v1()

    # Set up a Socket.IO namespace for world events.
    @io = io.of '/' + @id
    @io.on 'connection', @connect

    # Reference a scene from file.
    munged = mungeUri @rootUri, @sceneUri

    # Load the scene using BABYLON.
    BABYLON.SceneLoader.Load munged.rootUri, munged.sceneUri, engine, (scene) =>
      console.log "Loaded: " + munged.sceneUri.path

      # Enable physics using default plugin (Oimo)
      if not scene.enablePhysics new BABYLON.Vector3(0, 0, -10)
        console.error "Unable to initialize physics."

      # Create an emitter that outputs updates for this scene.
      # TODO: actually diff which meshes changed position.
      scene.afterRender = =>
        updates = []
        for mesh in scene.meshes
          updates.push
            id: mesh.id
            p: mesh.position.asArray()
            r: mesh.rotation.asArray()
        @io.emit 'update', updates

      # Add the scene as an accessible member.
      @scene = scene
      @diffs =
        add: {}
        remove: []

  # Tell a client how to connect to this world.
  # TODO: this probably doesn't need to happen inside World?
  initialize: (socket) =>
    socket.emit 'world',
      id: @id
      rootUri: @rootUri
      sceneUri: @sceneUri

    socket.on 'disconnect', =>
      @disconnect socket

    socket.on 'execute', (command) =>
      @execute socket, command

  # A player has disconnected.
  disconnect: (socket) =>
    # TODO: Remove the player avatar from this world.

  # A player has connected.
  connect: (socket) =>
    # Add objects not in original world.
    for id, mesh in @diffs.add
      socket.emit 'add', id, mesh

    # Remove objects no longer in original world.
    for id in @diffs.remove
      socket.emit 'remove', id

  execute: (socket, command) =>
    # Create the sandbox scope for the player command.
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

      remove: (name) =>
        mesh = @scene.getMeshByName(name)
        if mesh?
          @remove(mesh.id)
          socket.emit 'output', 'REMOVE SUCCESS: ' + name
        else
          socket.emit 'output', 'REMOVE FAILED: ' + name

      list: () =>
        socket.emit 'output', 'MESHES: ' + (mesh.name for mesh in @scene.meshes)

    # Attempt to execute a player command in the sandbox.        
    console.log 'Executing: ', command
    try
        vm = new VM { timeout: 100, sandbox: sandbox }
        vm.run command
    catch err
        console.error err
        socket.emit 'output', '[FAILED] ' + err

  update: =>
    # Step physics forward and send out update.
    if @scene?
      @scene.render()

    # Re-execute object scripts as necessary.
    @vm # TODO: DO STUFF

  # Add an object to the world.
  add: (name, rootUri, sceneUri, callback) =>
    # Create a mesh structure to track what was loaded.
    mesh =
      name: name
      rootUri: rootUri
      sceneUri: sceneUri

    # Reference a scene from file.
    munged = mungeUri mesh.rootUri, mesh.sceneUri

    # Load the munged mesh.
    BABYLON.SceneLoader.ImportMesh name, munged.rootUri, munged.sceneUri, @scene, (newMeshes, particleSystems, skeletons) =>

      # Extract mesh ID from the first loaded mesh.
      id = newMeshes[0].id

      # Add the loaded mesh to the diff structure and send to clients.
      @diffs.add[id] = mesh
      @io.emit 'add', id, mesh

      # Trigger callback with id of loaded mesh.
      if callback?
        callback id

  # Remove an object from the world.
  remove: (id) =>
    # Remove mesh from diff structure.
    if id in @diffs.add
      delete @diffs[id]
    else
      @diffs.remove.push id

    # Remove mesh from canonical world.
    mesh = @scene.getMeshByID id
    if mesh?
      mesh.dispose()
      @io.emit 'remove', id

module.exports = World
