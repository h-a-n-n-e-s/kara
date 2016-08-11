{BufferedProcess} = require 'atom'

module.exports = Kara =
  
  activate: () ->
    
    atom.commands.add 'atom-workspace', 'kara:run': => @run('')
    atom.commands.add 'atom-workspace', 'kara:go': => @run('go')
    atom.commands.add 'atom-workspace', 'kara:cancel': => @cancel()
  
  
  run: (goSwitch) ->
    
    # get full path, filename, suffix, and directory of currently active file ----------------------
    editor = atom.workspace.getActiveTextEditor()
    buffer = editor?.getBuffer()
    path = buffer?.getPath()
    filename = path?.substr(path.lastIndexOf('/')+1,path.length)
    dir = path?.substr(0,path.lastIndexOf('/'))
    suffix = path?.substr(path.lastIndexOf('.')+1)
    #projectDir = atom.project.getPaths() # get project directories in an array
    
    # close kara pane if it exists and save all files in the editor --------------------------------
    for pane in atom.workspace.getPanes()
      pane.destroy() if atom.views.getView(pane).className is 'pane kara'
    currentPane = atom.workspace.getActivePane()
    currentPane.saveItems()
    
    # create new pane 'karaPane' and attach a view -------------------------------------------------
    karaPane = currentPane.splitRight()
    atom.workspace.activatePreviousPane() # bring focus back to editor
    karaPaneElement = atom.views.getView(karaPane)
    karaPaneElement.classList.add('kara')
    bob = document.createElement('body')
    bob.classList.add('body')
    karaPaneElement.appendChild(bob)
    div = document.createElement('div')
    div.classList.add('native-key-bindings')
    div.tabIndex = -1 # this together with the native-key-bindings class allows for copyable text
    bob.appendChild(div)
    
    # preparation for rendering progress bar output from Povray ------------------------------------
    rendering = false
    buffer = ''
    render = document.createElement('pre')
    render.classList.add('render')
    
    # add text with class 'tag' to div -------------------------------------------------------------
    appendPre = (tag, text) ->
      message = document.createElement('pre')
      message.classList.add(tag)
      message.textContent = text
      div.appendChild(message)
      message.scrollHeight
    
    # scroll behavior: only scroll down to show new text if currently scrolled to bottom -----------
    overflow = false
    scrollChecker = (height) ->
      overlap = bob.scrollHeight - karaPaneElement.scrollHeight
      if overflow and overlap - bob.scrollTop is height # true if currently scrolled to bottom
        bob.scrollTop = overlap
      if not overflow and overlap > 0 # initial scroll when text hits bottom the first time
        overflow = true
        bob.scrollTop = overlap
    
    # output ---------------------------------------------------------------------------------------
    if path.match('com~apple~CloudDocs') # cut lengthy iCloud path name
      path = '--iCloud--'+path.substr(path.lastIndexOf('com~apple~CloudDocs')+19,path.length)
    if goSwitch is ''
      appendPre('output', 'file:  '+path)
    else
      appendPre('output', 'go:  '+path)
    stdout = (out) -> # called if karaProcess writes to stdout
      if not rendering and out.substr(0,5) isnt '|||||'
        outHeight = appendPre('stdout', out)
        scrollChecker(outHeight)
      # check if rendering progress bar output from Povray started
      if suffix in ['pov','inc','ini'] and out.substr(out.length-8,7) is '90%   |'
        rendering = true
        div.appendChild(render)
    stderr = (out) -> # called if karaProcess writes to stderr
      outHeight = appendPre('stderr', out)
      scrollChecker(outHeight)
    exit = (code) ->
      outHeight = appendPre('output', 'Process finished with exit status '+code+'.')
      scrollChecker(outHeight)
    
    # run the karaProcess --------------------------------------------------------------------------
    command = __dirname+'/run' # absolute path is necessary since we'll change cwd
    args = [filename+goSwitch]
    options = # set working directory
      cwd: dir
    karaProcess = new BufferedProcess({command, args, options, stdout, stderr, exit})
    
    # override the full line buffering for rendering progress bar output from Povray ---------------
    karaProcess.process.stdout.on 'data', (data) =>
      if rendering and data.substr(0,1) is '|'
        scrollChecker(15)
        buffer += data
        if buffer.length is 50 then rendering = false
        render.textContent = buffer
  
  
  cancel: ->
    editor = atom.workspace.getActiveTextEditor()
    buffer = editor?.getBuffer()
    path = buffer?.getPath()
    suffix = path?.substr(path.lastIndexOf('.')+1)
    if suffix not in ['pov','inc','ini','f90']
      atom.notifications.addWarning('I\'m not sure what to cancel.')
    else
      command = __dirname+'/run'
      if suffix in ['pov','ini','inc']
        args = ['cancelPovray']
      else
        args = ['cancelFortran']
      stdout = (output) -> console.log(output)
      stderr = (output) -> console.log(output)
      cancelProcess = new BufferedProcess({command, args, stdout, stderr})
      atom.notifications.addInfo('Process canceled.')
