/*global EventEmitter*/
angular.module('salty-spork').factory("pusher",
  ['$http', '$rootScope', 'user', function($http, $rootScope, user) {

  var ee = new EventEmitter();
  var pusher = new window.Pusher('7cdb1cc4d12f8d5a1959');
  var globalChannel = pusher.subscribe('global');
  var userChannel;

  pusher.connection.bind('disconnected', function() {
    $.notify.error("Oops, your connection may have been interrupted. Reconnecting...");
  });

  globalChannel.bind('game_start', function(message) {
    ee.emit("game_start", message);
  });

  globalChannel.bind('game_end', function(message) {
    ee.emit("game_end", message);
  });

  user.getStatus.then(function(status) {
    if (!status.loggedIn) return;
    userChannel = pusher.subscribe('user.' + status.user.id);

    userChannel.bind('wallet_update', function(message) {
      ee.emit("wallet_update", message);
    });
  });

  return ee;
}]);
