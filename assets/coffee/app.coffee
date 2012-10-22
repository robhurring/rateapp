window.WebFontConfig =
  google:
    families: ['Lobster', 'The Girl Next Door', 'Archivo Black']

class GaugeWrapper
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

$ ->
  window.gw = new GaugeWrapper('.topic_meter')
  gw.set 12