
window.App || (window.App = {});

App.GaugeWrapper = (function() {
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

App.ConnectionManager = (function() {

  function ConnectionManager(delegate) {
    var _this = this;
    this.delegate = delegate;
    this.loadAppConfig(function() {
      return _this.setupPusher();
    });
  }

  ConnectionManager.prototype.loadAppConfig = function(callback) {
    var _this = this;
    return $.getJSON('/config.json', function(data) {
      _this.appConfig = data;
      return callback();
    });
  };

  ConnectionManager.prototype.setupPusher = function() {
    var WEB_SOCKET_DEBUG, channel, pusher,
      _this = this;
    if (this.appConfig.pusher.debug != null) {
      Pusher.log = function(message) {
        return typeof console !== "undefined" && console !== null ? console.log(message) : void 0;
      };
      WEB_SOCKET_DEBUG = true;
    }
    pusher = new Pusher(this.appConfig.pusher.key);
    pusher.connection.bind('state_change', function(states) {
      return _this.delegate.trigger('app:state_change', states);
    });
    pusher.connection.bind('connecting', function() {
      return _this.delegate.trigger('app:connecting');
    });
    pusher.connection.bind('connected', function() {
      return _this.delegate.trigger('app:connected');
    });
    pusher.connection.bind('disconnected', function() {
      return _this.delegate.trigger('app:disconnected');
    });
    channel = pusher.subscribe(this.appConfig.pusher.channel);
    return this.delegate.trigger('app:channel:subscribed', channel);
  };

  return ConnectionManager;

})();

App.ChannelEventManager = (function() {

  function ChannelEventManager(channel) {
    this.channel = channel;
    this.channel.bind('score-changed', this.scoreChanged);
  }

  ChannelEventManager.prototype.scoreChanged = function(data) {
    return console.log(data);
  };

  return ChannelEventManager;

})();

App.VoteManager = (function() {

  function VoteManager() {}

  return VoteManager;

})();

$(function() {
  App.delegate = $(document);
  App.connectionManager = new App.ConnectionManager(App.delegate);
  App.gauge = new App.GaugeWrapper('.topic_meter');
  App.gauge.set(0.1);
  ($(document)).bind('app:connecting', function() {
    return ($('#connectionNotice')).slideDown();
  });
  ($(document)).bind('app:connected', function() {
    return ($('#connectionNotice')).slideUp();
  });
  return ($(document)).bind('app:channel:subscribed', function(_, channel) {
    return App.eventManager = new App.ChannelEventManager(channel);
  });
});
