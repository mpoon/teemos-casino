angular.module('teemos-casino').factory('user',
  ['$http', '$q', function($http, $q) {

    var deferred = $q.defer();
    var ee = new EventEmitter();
    var status = {};

    $http.get('/api/user')
    .success(function(user) {
      status.user = user;
      status.loggedIn = true;

      _.defer(function() {
        ee.updateWallet(status.user.wallet);
      });

      mixpanel.track(
        'login_success',
        { 'user': user.name });

      deferred.resolve(status);
    }).error(function(data, status_code) {
      status.user = null;
      status.loggedIn = false;

      mixpanel.track(
        'login_failure',
        { 'status_code': status_code });

      deferred.resolve(status);
    });

    ee.getStatus = deferred.promise;

    ee.updateWallet = function(amount) {
      ee.emit('wallet', amount);
    };

    return ee;
  }]);
