var socket = io();

socket.on('output', function (output) {
    console.log("RESPONSE: " + output);
    $('#response').append("<li>" + output + "</li>");
    $('#response').animate({
        scrollTop: $("#response").scrollHeight
    }, 300);
});

var langTools = ace.require("ace/ext/language_tools");
var editor = ace.edit("editor");
editor.getSession().setMode("ace/mode/javascript");
editor.setOptions({enableBasicAutocompletion: true});

editor.commands.addCommand({
    name: 'execute',
    bindKey: {win: 'Ctrl-Enter',  mac: 'Command-Enter'},
    exec: function(editor) {
        socket.emit('execute', editor.getValue());
        console.log("Executing command.");
    },
    readOnly: true // false if this command should not apply in readOnly mode
});