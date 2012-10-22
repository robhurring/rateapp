var bootstrap, loadAppConfig,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

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

App.ConnectionManager = (function(_super) {

  __extends(ConnectionManager, _super);

  function ConnectionManager(pusherConfig) {
    this.pusherConfig = pusherConfig;
    this.setupPusher();
  }

  ConnectionManager.prototype.setupPusher = function() {
    var WEB_SOCKET_DEBUG, channel, pusher,
      _this = this;
    if (this.pusherConfig.debug != null) {
      Pusher.log = function(message) {
        return typeof console !== "undefined" && console !== null ? console.log(message) : void 0;
      };
      WEB_SOCKET_DEBUG = true;
    }
    pusher = new Pusher(this.pusherConfig.key);
    pusher.connection.bind('state_change', function(states) {
      return _this.trigger('state_change', states);
    });
    pusher.connection.bind('connecting', function() {
      return _this.trigger('connecting');
    });
    pusher.connection.bind('connected', function() {
      return _this.trigger('connected');
    });
    pusher.connection.bind('disconnected', function() {
      return _this.trigger('disconnected');
    });
    channel = pusher.subscribe(this.pusherConfig.channel);
    return this.trigger('channel:subscribed', channel);
  };

  return ConnectionManager;

})(AbstractEventsDispatcher);

App.ViewManager = (function() {

  function ViewManager() {
    this.header = $('.topic header');
    this.gauge = new App.GaugeWrapper('.topic_meter');
    ($('.upvote a')).on('click', this.upvote);
    ($('.downvote a')).on('click', this.downvotea);
    this.updateHeader();
    this.updateGauge();
  }

  ViewManager.prototype.updateHeader = function() {
    return this.header.html(App.config.topic.name);
  };

  ViewManager.prototype.updateGauge = function() {
    return this.gauge.set(parseInt(App.config.topic.score));
  };

  ViewManager.prototype.upvote = function() {
    return console.log('voteup');
  };

  ViewManager.prototype.downvote = function() {
    return console.log('downvote');
  };

  return ViewManager;

})();

bootstrap = function() {
  var connectionManager, viewManager;
  connectionManager = new App.ConnectionManager(App.config.pusher);
  viewManager = new App.ViewManager;
  connectionManager.bind('connecting', function() {
    return ($('#connectionNotice')).slideDown();
  });
  return connectionManager.bind('connected', function() {
    return ($('#connectionNotice')).slideUp();
  });
};

loadAppConfig = function(callback) {
  var _this = this;
  return $.getJSON('/config.json', function(data) {
    App.config = data;
    return callback();
  });
};

$(function() {
  return loadAppConfig(function() {
    return bootstrap();
  });
});
