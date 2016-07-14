#KaraView = require './kara-view'
Stop = require './stop'
{CompositeDisposable} = require 'atom'

module.exports = Kara =
  #karaView: null
  #modalPanel: null
  stop: null
  subscriptions: null

  activate: (state) ->
    # @karaView = new KaraView(state.karaViewState)
    # @modalPanel = atom.workspace.addModalPanel(item: @karaView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'kara:toggle': => @toggle()

  deactivate: ->
    # @modalPanel.destroy()
    # @subscriptions.dispose()
    # @karaView.destroy()

  serialize: ->
    # karaViewState: @karaView.serialize()

  toggle: ->
    console.log 'Kara was toggled!'
    stop = new Stop
    stop.cancelPovray()
    # if @modalPanel.isVisible()
    #   @modalPanel.hide()
    # else
    #   @modalPanel.show()
