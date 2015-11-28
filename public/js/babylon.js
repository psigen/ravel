var socket = io();
var canvas = document.getElementById("renderCanvas");
var engine = new BABYLON.Engine(canvas, true);
var scene = undefined;

BABYLON.SceneLoader.ForceFullSceneLoadingForIncremental = true;
BABYLON.SceneLoader.Load("./assets/Samples/Scenes/hillvalley/", "HillValley.babylon", engine, function (newScene) {
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
    
    newScene.executeWhenReady(function() {
        engine.runRenderLoop(function() {
            newScene.render();
        });
    });

    scene = newScene;
});

// Update the poses of the meshes in the world on server update.
socket.on('update', function (updates) {
    updates.forEach(function(update) {
        if (scene) {
            var mesh = scene.getMeshByID(update.id);
            if (mesh) {
                mesh.position = BABYLON.Vector3.FromArray(update.p, 0);
                mesh.rotation = BABYLON.Vector3.FromArray(update.r, 0);
            } else {
                console.warn("Unknown update: " + update.id);
            }
        }
    });
})