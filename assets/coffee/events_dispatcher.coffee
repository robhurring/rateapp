class EventsDispatcher
  callbacks: {}

  bind: (event_name, callback) ->
    @callbacks[event_name] ||= []
    @callbacks[event_name].push callback
    @

  trigger: (event_name, data) ->
    @dispatch event_name, data
    @

  dispatch: (event_name, data) ->
    chain = @callbacks[event_name]
    callback data for callback in chain if chain?
