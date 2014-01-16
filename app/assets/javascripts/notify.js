$.noty.defaults = {
  layout: 'top',
  theme: 'speechBubble',
  type: 'alert',
  text: '',
  dismissQueue: true, // If you want to use queue feature set this true
  template: '<div class="bottom-notification"><div class="notification-content"><p class="noty_text"></p></div></div><div class="notification-arrow"></div>',
  animation: {
    open: {height: 'toggle'},
    close: {height: 'toggle'},
    easing: 'swing',
    speed: 500 // opening & closing animation speed
  },
  timeout: 10 * 1000, // delay for closing event. Set false for sticky notifications
  force: false, // adds notification to the beginning of queue when set to true
  modal: false,
  maxVisible: 10, // you can set max visible notification for dismissQueue true option
  closeWith: ['click'], // ['click', 'button', 'hover']
  callback: {
    onShow: function() {},
    afterShow: function() {},
    onClose: function() {},
    afterClose: function() {}
  },
  buttons: false // an array of buttons
};

$.speechBubble = {
  write: function(msg, options) {
    options = options || {};
    options.text = msg;
    $('.bottom-notification-container').noty(options);
  }
};
