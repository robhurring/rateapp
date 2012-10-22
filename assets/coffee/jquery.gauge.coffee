$.fn.gauge = (options) ->
  @each ->
    self = ($ this)
    data = self.data()

    if data.gauge?
      data.gauge.stop()
      delete data.gauge

    if options?
      data.gauge = new Gauge(@).setOptions(options)

    @