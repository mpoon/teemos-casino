angular.module('salty-spork').factory('user',
  ['$http', '$q', function($http, $q) {

    var deferred = $q.defer();
    var status = {};

    $http.get('/api/v1/user')
    .success(function(user) {
      status.user = user;
      status.loggedIn = true;

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

    return {
      getStatus: deferred.promise
    };
  }]);
