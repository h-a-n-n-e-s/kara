{BufferedProcess} = require 'atom'
Misc = require './misc'

module.exports =
class Stop
  constructor: ->

  cancelPovray: ->
    misc = new Misc
    suffix = misc.currentFileSuffix()
    if suffix not in ['pov','ini','inc','f90']
      atom.notifications.addWarning('Not sure what to cancel.')
    else
      command = '/Applications/povray'
      if suffix in ['pov','ini','inc']
        args = ['cancelPovray']
      else
        args = ['cancelFortran']
      stdout = (output) -> console.log(output)
      stderr = (output) -> console.log(output)
      process = new BufferedProcess({command, args, stdout, stderr})
      atom.notifications.addWarning('Process canceled.')

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  getElement: ->
    @element
