var AbstractEventsDispatcher;

AbstractEventsDispatcher = (function() {

  function AbstractEventsDispatcher() {}

  AbstractEventsDispatcher.prototype.callbacks = {};

  AbstractEventsDispatcher.prototype.global_callbacks = [];

  AbstractEventsDispatcher.prototype.bind = function(event_name, callback) {
    var _base;
    (_base = this.callbacks)[event_name] || (_base[event_name] = []);
    this.callbacks[event_name].push(callback);
    return this;
  };

  AbstractEventsDispatcher.prototype.trigger = function(event_name, data) {
    this.dispatch(event_name, data);
    this.dispatch_global(event_name, data);
    return this;
  };

  AbstractEventsDispatcher.prototype.bind_all = function(callback) {
    this.global_callbacks.push(callback);
    return this;
  };

  AbstractEventsDispatcher.prototype.dispatch = function(event_name, data) {
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

  AbstractEventsDispatcher.prototype.dispatch_global = function(event_name, data) {
    var callback, _i, _len, _ref, _results;
    _ref = this.global_callbacks;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      callback = _ref[_i];
      _results.push(callback(event_name, data));
    }
    return _results;
  };

  return AbstractEventsDispatcher;

})();
