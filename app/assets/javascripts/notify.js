$.noty.defaults = {
  layout: 'top',
  theme: 'defaultTheme',
  type: 'alert',
  text: '',
  dismissQueue: true, // If you want to use queue feature set this true
  template: '<div class="noty_message"><span class="noty_text"></span><div class="noty_close"></div></div>',
  animation: {
    open: {height: 'toggle'},
    close: {height: 'toggle'},
    easing: 'swing',
    speed: 500 // opening & closing animation speed
  },
  timeout: 5 * 1000, // delay for closing event. Set false for sticky notifications
  force: false, // adds notification to the beginning of queue when set to true
  modal: false,
  maxVisible: 5, // you can set max visible notification for dismissQueue true option
  closeWith: ['click'], // ['click', 'button', 'hover']
  callback: {
    onShow: function() {},
    afterShow: function() {},
    onClose: function() {},
    afterClose: function() {}
  },
  buttons: false // an array of buttons
};

$.notify = {
  _dispatch: function(msg, options) {
    options.text = msg;
    window.noty(options);
  },
  alert: function(msg, options) {
    options = _.extend(options || {}, {type: 'alert'});
    this._dispatch(msg, options);
  },
  success: function(msg, options) {
    options = _.extend(options || {}, {type: 'success'});
    this._dispatch(msg, options);
  },
  error: function(msg, options) {
    options = _.extend(options || {}, {type: 'error'});
    this._dispatch(msg, options);
  }
};
