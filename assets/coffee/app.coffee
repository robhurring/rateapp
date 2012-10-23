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
    @unset 'vote'

  downVote: ->
    @save vote: -1
    @unset 'vote'

  updateName: (new_name) ->
    @save new_name: new_name
    @unset 'new_name'

  resetScore: ->
    @save reset: 1
    @unset 'reset'

class App.Views.ActionSheet extends Backbone.View
  el: '#action_sheet'
  events:
    'click .close': 'rollUp'

  initialize: ->
    @subview = @options.subview
    @subview.options.actionSheet = @

  rollUp: ->
    @$el.slideUp()

  render: ->
    ($ '.content', @$el).html @subview.render().el
    @$el.slideDown()
    @

class App.Views.ActionsView extends Backbone.View
  events:
    'click [data-action=reset_meter]': 'resetMeter'
    'click [data-action=change_topic]': 'changeTopic'

  initialize: ->
    @template = _.template ($ '[data-template=meter_actions]').html()

  resetMeter: ->
    @model.resetScore()
    @options.actionSheet.rollUp()

  changeTopic: ->
    @model.updateName ($ '[data-input=topic_name]', @$el).val()
    @options.actionSheet.rollUp()

  render: ->
    ($ @el).html @template()
    ($ '[data-input=topic_name]', @$el).val @model.get('name')
    @

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
    subview = new App.Views.ActionsView(model: @model)
    infoView = new App.Views.ActionSheet(subview: subview)
    infoView.render()

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

    channel.bind 'topic-reset', ->
      App.topic.fetch()

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
