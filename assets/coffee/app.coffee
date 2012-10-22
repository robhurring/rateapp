window.App ||= {}

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

class App.ConnectionManager
  constructor: (delegate) ->
    @delegate = delegate
    @loadAppConfig =>
      @setupPusher()

  loadAppConfig: (callback) ->
    $.getJSON '/config.json', (data) =>
      @appConfig = data
      callback()

  setupPusher: ->
    if @appConfig.pusher.debug?
      Pusher.log = (message) -> console?.log message
      WEB_SOCKET_DEBUG = true

    pusher = new Pusher @appConfig.pusher.key

    pusher.connection.bind 'state_change', (states) =>
      @delegate.trigger 'app:state_change', states

    pusher.connection.bind 'connecting', =>
      @delegate.trigger 'app:connecting'

    pusher.connection.bind 'connected', =>
      @delegate.trigger 'app:connected'

    pusher.connection.bind 'disconnected', =>
      @delegate.trigger 'app:disconnected'

    channel = pusher.subscribe @appConfig.pusher.channel
    @delegate.trigger 'app:channel:subscribed', channel

class App.ChannelEventManager
  constructor: (@channel) ->
    @channel.bind 'score-changed', @scoreChanged

  scoreChanged: (data) ->
    console.log data

class App.VoteManager

$ ->
  App.delegate = ($ document)
  App.connectionManager = new App.ConnectionManager App.delegate

  App.gauge = new App.GaugeWrapper('.topic_meter')
  App.gauge.set 0.1

  ($ document).bind 'app:connecting', ->
    ($ '#connectionNotice').slideDown()

  ($ document).bind 'app:connected', ->
    ($ '#connectionNotice').slideUp()

  ($ document).bind 'app:channel:subscribed', (_, channel) ->
    App.eventManager = new App.ChannelEventManager channel
