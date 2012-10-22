var GaugeWrapper;

window.WebFontConfig = {
  google: {
    families: ['Lobster', 'The Girl Next Door', 'Archivo Black']
  }
};

GaugeWrapper = (function() {
  var colorOptions, gaugeOptions;

  colorOptions = {
    good: '#C7DB70',
    bad: '#D86D78',
    awesome: '#E4A8CF',
    background: '#e0e0e0'
  };

  gaugeOptions = {
    lines: 12,
    angle: 0,
    lineWidth: 0.44,
    pointer: {
      length: 0.9,
      strokeWidth: 0.035,
      color: '#000000'
    },
    colorStart: '#fff',
    colorStop: '#2989d8',
    strokeColor: '#e0e0e0',
    generateGradient: false
  };

  function GaugeWrapper(selector) {
    var target;
    this.selector = selector;
    target = ($(this.selector))[0];
    this.gauge = new Gauge(target).setOptions(gaugeOptions);
    this.gauge.maxValue = 100;
    this.gauge.animationSpeed = 10;
  }

  GaugeWrapper.prototype.set = function(value) {
    if (value === (this.gauge.maxValue / 2)) {
      this.gauge.options.colorStop = colorOptions.awesome;
    } else if (value < (this.gauge.maxValue / 2)) {
      this.gauge.options.colorStop = colorOptions.bad;
    } else {
      this.gauge.options.colorStop = colorOptions.good;
    }
    return this.gauge.set(value);
  };

  return GaugeWrapper;

})();

$(function() {
  window.gw = new GaugeWrapper('.topic_meter');
  return gw.set(12);
});
