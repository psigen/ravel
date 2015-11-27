{VM} = require 'vm2'
p2 = require 'p2'

class World
  constructor: ->
    @physics = new p2.World
      gravity
    @vm = new VM
      timeout: 100,
      sandbox: {}

  load: (svg) ->


  update: ->
    console.log "Updated world."
