angular.module('teemos-casino').factory('betMode',
  ['$http', '$q', function($http, $q) {

    var deferred = $q.defer();
    var bets = {};

    $http.get('/api/bet/status')
    .success(function(bets) {
      // TODO: error checking
      deferred.resolve(bets);
    }).error(function() {
      bets = [{
        'mode': 'closed',
        'gameId': null,
        'amount': null,
        'team': null,
        'expires': null,
        'betId': null,
        'kind': null
      }];

      deferred.resolve(bets);
    });

    return {
      get: function() {
        return deferred.promise;
      }
    };
  }]);
