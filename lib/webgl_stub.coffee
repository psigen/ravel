###
Fake implementation of WebGL stub.
###
class Buffer

class Shader

class WebGL
  bindBuffer: ->
    # Do nothing.

  bufferData: ->
    # Do nothing.

  clear: ->
    # Do nothing.

  clearColor: ->
    # Do nothing.

  clearDepth: ->
    # Do nothing.

  compileShader: ->
    # Do nothing.

  createBuffer: ->
    return new Buffer

  createShader: ->
    return new Shader

  enable: ->
    # Do nothing.

  deleteBuffer: ->
    # Do nothing.

  depthMask: ->
    # Do nothing.

  getParameter: ->
    # Do nothing.   

  getExtension: ->
    # Do nothing.

  getShaderInfoLog: ->
    # Do nothing.   

  getShaderParameter: ->
    # Do nothing.   

  shaderSource: ->
    # Do nothing.

  viewport: ->
    # Do nothing.

class Element
  constructor: ->
    @style = 
      left: "50%"
      opacity: 1.0
      position: "absolute"

  addEventListener: ->
    # Do nothing.

  appendChild: ->
    # Do nothing.

  getContext: (name, options) ->
    if name == 'webgl' or name == 'experimental-webgl'
      return new WebGL
    else
      return undefined

  getBoundingClientRect: ->
    left: 0
    top: 0
    width: 0
    height: 0

class Document
  constructor: ->
    @body = new Element

  addEventListener: ->
    # Do nothing.

  createElement: ->
    return new Element

class Image extends Element

# Create placeholders for browser window objects.
global.window =
  addEventListener: () ->
  setTimeout: setTimeout
  location:
    href:
      __dirname

global.navigator = {}
global.alert = console.log
global.document = new Document();
global.Image = Image

`
function HTMLElement() {};
global.HTMLElement = HTMLElement;
`