
$.fn.gauge = function(options) {
  return this.each(function() {
    var data, self;
    self = $(this);
    data = self.data();
    if (data.gauge != null) {
      data.gauge.stop();
      delete data.gauge;
    }
    if (options != null) {
      data.gauge = new Gauge(this).setOptions(options);
    }
    return this;
  });
};
