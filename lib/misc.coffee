module.exports =
class Misc
  constructor: ->

  currentFileSuffix: ->
    editor = atom.workspace.getActiveTextEditor()
    buffer = editor?.getBuffer()
    file = buffer?.getPath()
    file?.substr(file.lastIndexOf('.')+1)
