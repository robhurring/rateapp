var EventsDispatcher;

EventsDispatcher = (function() {

  function EventsDispatcher() {}

  EventsDispatcher.prototype.callbacks = {};

  EventsDispatcher.prototype.bind = function(event_name, callback) {
    var _base;
    (_base = this.callbacks)[event_name] || (_base[event_name] = []);
    this.callbacks[event_name].push(callback);
    return this;
  };

  EventsDispatcher.prototype.trigger = function(event_name, data) {
    this.dispatch(event_name, data);
    return this;
  };

  EventsDispatcher.prototype.dispatch = function(event_name, data) {
    var callback, chain, _i, _len, _results;
    chain = this.callbacks[event_name];
    if (chain != null) {
      _results = [];
      for (_i = 0, _len = chain.length; _i < _len; _i++) {
        callback = chain[_i];
        _results.push(callback(data));
      }
      return _results;
    }
  };

  return EventsDispatcher;

})();
