var socket = io();
var canvas = document.getElementById("renderCanvas");
var engine = new BABYLON.Engine(canvas, true);
var scene = new BABYLON.Scene(engine);

// Set up engine settings.
BABYLON.SceneLoader.ForceFullSceneLoadingForIncremental = true;

// Switch to a new world.
// world = { id: [ID], uri: [URI] }
socket.on('world', function (newWorld) {

    // Load the new world scene.
    BABYLON.SceneLoader.Load(newWorld.rootUri, newWorld.sceneUri, engine, function (newScene) {

        // Configure the camera controls for this scene.
        // TODO: implement an actual player avatar.
        newScene.activeCamera.attachControl(canvas);
        if (newScene.activeCamera.keysUp) {
            newScene.activeCamera.keysUp.push(90); // Z
            newScene.activeCamera.keysUp.push(87); // W
            newScene.activeCamera.keysDown.push(83); // S
            newScene.activeCamera.keysLeft.push(65); // A
            newScene.activeCamera.keysLeft.push(81); // Q
            newScene.activeCamera.keysRight.push(69); // E
            newScene.activeCamera.keysRight.push(68); // D
        }

        // Add this scene to the global rendering loop.
        newScene.executeWhenReady(function() {
            engine.runRenderLoop(function() {
                newScene.render();
            });
        });

        // Update the poses of the meshes in the world on server update.
        // TODO: This should not require 'window.location.origin':
        // https://github.com/socketio/socket.io-client/issues/812#issuecomment-132659821
        var worldSocket = io(window.location.origin + '/' + newWorld.id);
        worldSocket.on('update', function (updates) {
            updates.forEach(function(update) {
                var mesh = newScene.getMeshByID(update.id);
                if (mesh) {
                    mesh.position = BABYLON.Vector3.FromArray(update.p, 0);
                    mesh.rotation = BABYLON.Vector3.FromArray(update.r, 0);
                } else {
                    console.warn("Unknown update: " + update.id);
                }
            });
        })

        // Set up shutdown hooks for this scene.
        newScene.onDispose = function () {
            worldSocket.disconnect();
        }

        // Switch to rendering the new scene and dispose the old one.
        var oldScene = scene;
        scene = newScene;
        oldScene.dispose();
    });
});
