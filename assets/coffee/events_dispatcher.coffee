class AbstractEventsDispatcher
  callbacks: {}
  global_callbacks: []

  bind: (event_name, callback) ->
    @callbacks[event_name] ||= []
    @callbacks[event_name].push callback
    @

  trigger: (event_name, data) ->
    @dispatch event_name, data
    @dispatch_global event_name, data
    @

  bind_all: (callback) ->
    @global_callbacks.push callback
    @

  dispatch: (event_name, data) ->
    chain = @callbacks[event_name]
    callback data for callback in chain if chain?

  dispatch_global: (event_name, data) ->
    callback event_name, data for callback in @global_callbacks

