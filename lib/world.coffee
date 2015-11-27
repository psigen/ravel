{VM} = require 'vm2'
p2 = require 'p2'

class World
  constructor: ->
    @physics = new p2.World
      gravity
    @vm = new VM
      timeout: 100,
      sandbox: {}
    setInterval @update, 1000.0 * @timestep

  load: (svg) ->
    # TODO: implement this.

  update: (timestep) ->
    console.log "Updated world."

    # Step physics forward by timestep.
    @world.step(timestep);

    # Re-execute object scripts as necessary.
    @vm # DO STUFF