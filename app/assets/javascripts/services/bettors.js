angular.module('teemos-casino').factory('bettors',
  ['$http', '$q', function($http, $q) {

    var deferred = $q.defer();
    var bettors = {
      'top': [],
      'bets': []
    };

    $http.get('/api/bettors')
    .success(function(result) {
      bettors = result;
      deferred.resolve(bettors);
    }).error(function() {
      deferred.resolve(bettors);
    });

    return {
      getStatus: function() {
        return deferred.promise;
      }
    };
  }]);
