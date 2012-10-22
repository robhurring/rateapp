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

class App.ConnectionManager extends AbstractEventsDispatcher
  constructor: (@pusherConfig) ->
    @setupPusher()

  setupPusher: ->
    if @pusherConfig.debug?
      Pusher.log = (message) -> console?.log message
      WEB_SOCKET_DEBUG = true

    pusher = new Pusher @pusherConfig.key

    pusher.connection.bind 'state_change', (states) =>
      @trigger 'state_change', states

    pusher.connection.bind 'connecting', =>
      @trigger 'connecting'

    pusher.connection.bind 'connected', =>
      @trigger 'connected'

    pusher.connection.bind 'disconnected', =>
      @trigger 'disconnected'

    channel = pusher.subscribe @pusherConfig.channel
    @trigger 'channel:subscribed', channel

class App.ViewManager
  constructor: ->
    @header = ($ '.topic header')
    @gauge = new App.GaugeWrapper '.topic_meter'
    ($ '.upvote a').on 'click', @upvote
    ($ '.downvote a').on 'click', @downvotea

    @updateHeader()
    @updateGauge()

  updateHeader: ->
    @header.html App.config.topic.name

  updateGauge: ->
    @gauge.set parseInt(App.config.topic.score)

  upvote: ->
    console.log 'voteup'

  downvote: ->
    console.log 'downvote'

bootstrap = ->
  connectionManager = new App.ConnectionManager App.config.pusher
  viewManager = new App.ViewManager

  connectionManager.bind 'connecting', ->
    ($ '#connectionNotice').slideDown()

  connectionManager.bind 'connected', ->
    ($ '#connectionNotice').slideUp()

loadAppConfig = (callback) ->
  $.getJSON '/config.json', (data) =>
    App.config = data
    callback()

$ ->
  loadAppConfig -> bootstrap()
