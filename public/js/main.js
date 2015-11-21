var socket = io();
socket.on('output', function (output) {
    $('#response').append("<li>" + output + "</li>");
    $('#response').animate({
        scrollTop: $("#response").scrollHeight()
    }, 300);
});

var langTools = ace.require("ace/ext/language_tools");
var editor = ace.edit("editor");
editor.getSession().setMode("ace/mode/javascript");
editor.setOptions({enableBasicAutocompletion: true});

// uses http://rhymebrain.com/api.html
var rhymeCompleter = {
    getCompletions: function(editor, session, pos, prefix, callback) {
        if (prefix.length === 0) { callback(null, []); return }
        $.getJSON(
            "http://rhymebrain.com/talk?function=getRhymes&word=" + prefix,
            function(wordList) {
                // wordList like [{"word":"flow","freq":24,"score":300,"flags":"bc","syllables":"1"}]
                callback(null, wordList.map(function(ea) {
                    return {name: ea.word, value: ea.word, score: ea.score, meta: "rhyme"}
                }));
            })
    }
}
langTools.addCompleter(rhymeCompleter);

editor.commands.addCommand({
    name: 'execute',
    bindKey: {win: 'Ctrl-Enter',  mac: 'Command-Enter'},
    exec: function(editor) {
        socket.emit('execute', editor.getValue());
        console.log("Executing command.");
    },
    readOnly: true // false if this command should not apply in readOnly mode
});