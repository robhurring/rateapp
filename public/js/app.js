var connect, initialize,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

window.App = {};

window.App.Views = {};

window.App.Models = {};

Backbone.emulateJSON = true;

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

  function ConnectionManager() {
    return ConnectionManager.__super__.constructor.apply(this, arguments);
  }

  ConnectionManager.prototype.connect = function() {
    var WEB_SOCKET_DEBUG, channel, pusher,
      _this = this;
    if (App.config.get('debug') != null) {
      Pusher.log = function(message) {
        return typeof console !== "undefined" && console !== null ? console.log(message) : void 0;
      };
      WEB_SOCKET_DEBUG = true;
    }
    pusher = new Pusher(App.config.get('key'));
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
    channel = pusher.subscribe(App.config.get('channel'));
    return this.trigger('channel:subscribed', channel);
  };

  return ConnectionManager;

})(EventsDispatcher);

App.Models.Config = (function(_super) {

  __extends(Config, _super);

  function Config() {
    return Config.__super__.constructor.apply(this, arguments);
  }

  Config.prototype.url = '/config';

  return Config;

})(Backbone.Model);

App.Models.Topic = (function(_super) {

  __extends(Topic, _super);

  function Topic() {
    return Topic.__super__.constructor.apply(this, arguments);
  }

  Topic.prototype.url = '/topic';

  Topic.prototype.upVote = function() {
    this.save({
      vote: 1
    });
    return this.unset('vote');
  };

  Topic.prototype.downVote = function() {
    this.save({
      vote: -1
    });
    return this.unset('vote');
  };

  Topic.prototype.updateName = function(new_name) {
    this.save({
      new_name: new_name
    });
    return this.unset('new_name');
  };

  Topic.prototype.resetScore = function() {
    this.save({
      reset: 1
    });
    return this.unset('reset');
  };

  return Topic;

})(Backbone.Model);

App.Views.ActionSheet = (function(_super) {

  __extends(ActionSheet, _super);

  function ActionSheet() {
    return ActionSheet.__super__.constructor.apply(this, arguments);
  }

  ActionSheet.prototype.el = '#action_sheet';

  ActionSheet.prototype.events = {
    'click .close': 'rollUp'
  };

  ActionSheet.prototype.initialize = function() {
    this.subview = this.options.subview;
    return this.subview.options.actionSheet = this;
  };

  ActionSheet.prototype.rollUp = function() {
    return this.$el.slideUp();
  };

  ActionSheet.prototype.render = function() {
    ($('.content', this.$el)).html(this.subview.render().el);
    this.$el.slideDown();
    return this;
  };

  return ActionSheet;

})(Backbone.View);

App.Views.ActionsView = (function(_super) {

  __extends(ActionsView, _super);

  function ActionsView() {
    return ActionsView.__super__.constructor.apply(this, arguments);
  }

  ActionsView.prototype.events = {
    'click [data-action=reset_meter]': 'resetMeter',
    'click [data-action=change_topic]': 'changeTopic'
  };

  ActionsView.prototype.initialize = function() {
    return this.template = _.template(($('[data-template=meter_actions]')).html());
  };

  ActionsView.prototype.resetMeter = function() {
    this.model.resetScore();
    return this.options.actionSheet.rollUp();
  };

  ActionsView.prototype.changeTopic = function() {
    this.model.updateName(($('[data-input=topic_name]', this.$el)).val());
    return this.options.actionSheet.rollUp();
  };

  ActionsView.prototype.render = function() {
    ($(this.el)).html(this.template());
    ($('[data-input=topic_name]', this.$el)).val(this.model.get('name'));
    return this;
  };

  return ActionsView;

})(Backbone.View);

App.Views.TopicView = (function(_super) {

  __extends(TopicView, _super);

  function TopicView() {
    return TopicView.__super__.constructor.apply(this, arguments);
  }

  TopicView.prototype.el = $('article.topic');

  TopicView.prototype.events = {
    'click .upvote a': 'upvote',
    'click .downvote a': 'downvote',
    'click .info a': 'openInfo'
  };

  TopicView.prototype.initialize = function() {
    this.header = $('header .name', this.el);
    this.info = $('header .info', this.el);
    this.gauge = new App.GaugeWrapper($('.topic_meter'));
    _.bindAll(this, 'render', 'modelSynced');
    this.model.on('change', this.render);
    return this.model.on('sync', this.modelSynced);
  };

  TopicView.prototype.upvote = function() {
    this.indicate('upvote');
    return this.model.upVote();
  };

  TopicView.prototype.downvote = function() {
    this.indicate('downvote');
    return this.model.downVote();
  };

  TopicView.prototype.openInfo = function() {
    var infoView, subview;
    subview = new App.Views.ActionsView({
      model: this.model
    });
    infoView = new App.Views.ActionSheet({
      subview: subview
    });
    return infoView.render();
  };

  TopicView.prototype.indicate = function(type) {
    ($("." + type + " .indicator", this.el)).show();
    return ($("." + type + " a", this.el)).hide();
  };

  TopicView.prototype.modelSynced = function() {
    return this.clearAllIndicators();
  };

  TopicView.prototype.clearAllIndicators = function() {
    ($('.indicator', this.el)).hide();
    return ($('a', this.el)).show();
  };

  TopicView.prototype.repositionInfo = function() {
    var pos;
    this.info.hide();
    pos = this.header.position();
    this.info.css({
      top: pos.top - 5,
      left: pos.left + this.header.width() + 5
    });
    return this.info.show();
  };

  TopicView.prototype.render = function() {
    this.header.html(this.model.get('name'));
    this.repositionInfo();
    this.gauge.set(this.model.get('percent'));
    return this;
  };

  return TopicView;

})(Backbone.View);

connect = function() {
  App.connectionManager.bind('connected', function() {
    return ($('#connectionNotice')).slideUp();
  });
  App.connectionManager.bind('disconnected', function() {
    return ($('#connectionNotice')).slideDown();
  });
  App.connectionManager.bind('channel:subscribed', function(channel) {
    channel.bind('score-changed', function(data) {
      return App.topic.set('percent', data.percent);
    });
    channel.bind('name-changed', function(data) {
      return App.topic.set('name', data.name);
    });
    return channel.bind('topic-reset', function() {
      return App.topic.fetch();
    });
  });
  return App.connectionManager.connect();
};

initialize = function() {
  App.config.fetch();
  App.topic.fetch();
  return App.config.on('change', function() {
    return connect();
  });
};

$(function() {
  App.connectionManager = new App.ConnectionManager();
  App.config = new App.Models.Config();
  App.topic = new App.Models.Topic({
    connection: App.connectionManager
  });
  App.topicView = new App.Views.TopicView({
    model: App.topic,
    connection: App.connectionManager
  });
  return initialize();
});
