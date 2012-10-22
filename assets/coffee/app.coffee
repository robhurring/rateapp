window.App = {}
window.App.Views = {}
window.App.Models = {}

Backbone.emulateJSON = true

class App.GaugeWrapper
  colorOptions =
    good: '#C7DB70'
    bad: '#D86D78'
    awesome: '#E4A8CF'
    background: '#e0e0e0'

  gaugeOptions =
    lines: 12
    angle: 0
    lineWidth: 0.44
    pointer:
      length: 0.9
      strokeWidth: 0.035
      color: '#000000'
    colorStart: '#fff'
    colorStop: '#2989d8'
    strokeColor: '#e0e0e0'
    generateGradient: false

  constructor: (@selector) ->
    target = ($ @selector)[0]
    @gauge = new Gauge(target).setOptions(gaugeOptions)
    @gauge.maxValue = 100
    @gauge.animationSpeed = 10

  set: (value) ->
    if value == (@gauge.maxValue / 2)
      @gauge.options.colorStop = colorOptions.awesome
    else if value < (@gauge.maxValue / 2)
      @gauge.options.colorStop = colorOptions.bad
    else
      @gauge.options.colorStop = colorOptions.good

    @gauge.set value

class App.ConnectionManager extends EventsDispatcher
  connect: ->
    if App.config.get('debug')?
      Pusher.log = (message) -> console?.log message
      WEB_SOCKET_DEBUG = true

    pusher = new Pusher App.config.get('key')

    pusher.connection.bind 'state_change', (states) =>
      @trigger 'state_change', states

    pusher.connection.bind 'connecting', =>
      @trigger 'connecting'

    pusher.connection.bind 'connected', =>
      @trigger 'connected'

    pusher.connection.bind 'disconnected', =>
      @trigger 'disconnected'

    channel = pusher.subscribe App.config.get('channel')
    @trigger 'channel:subscribed', channel

class App.Models.Config extends Backbone.Model
  url: '/config'

class App.Models.Topic extends Backbone.Model
  url: '/topic'

  upVote: ->
    @save vote: 1

  downVote: ->
    @save vote: -1

class App.Views.TopicView extends Backbone.View
  el: ($ 'article.topic')
  events:
    'click .upvote a': 'upvote'
    'click .downvote a': 'downvote'
    'click .info a': 'openInfo'

  initialize: ->
    @header = ($ 'header .name', @el)
    @info = ($ 'header .info', @el)
    @gauge = new App.GaugeWrapper($ '.topic_meter')

    _.bindAll @, 'render', 'modelSynced'
    @model.on 'change', @render
    @model.on 'sync', @modelSynced

  upvote: ->
    @indicate 'upvote'
    @model.upVote()

  downvote: ->
    @indicate 'downvote'
    @model.downVote()

  openInfo: ->
    console.log 'ohai'

  indicate: (type) ->
    ($ ".#{type} .indicator", @el).show()
    ($ ".#{type} a", @el).hide()

  modelSynced: ->
    @clearAllIndicators()

  clearAllIndicators: ->
    ($ '.indicator', @el).hide()
    ($ 'a', @el).show()

  repositionInfo: ->
    @info.hide()
    pos = @header.position()
    @info.css top: pos.top - 5, left: pos.left + @header.width() + 5
    @info.show()

  render: ->
    @header.html @model.get('name')
    @repositionInfo()
    @gauge.set @model.get('percent')
    @

connect = ->
  App.connectionManager.bind 'connected', ->
    ($ '#connectionNotice').slideUp()

  App.connectionManager.bind 'disconnected', ->
    ($ '#connectionNotice').slideDown()

  App.connectionManager.bind 'channel:subscribed', (channel) ->
    channel.bind 'score-changed', (data) ->
      App.topic.set 'percent', data.percent

    channel.bind 'name-changed', (data) ->
      App.topic.set 'name', data.name

  App.connectionManager.connect()

initialize = ->
  App.config.fetch()
  App.topic.fetch()

  App.config.on 'change', ->
    connect()

$ ->
  App.connectionManager = new App.ConnectionManager()
  App.config = new App.Models.Config()
  App.topic = new App.Models.Topic(connection: App.connectionManager)
  App.topicView = new App.Views.TopicView model: App.topic, connection: App.connectionManager

  initialize()
