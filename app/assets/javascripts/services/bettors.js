angular.module('salty-spork').factory('bettors',
  ['$http', '$q', function($http, $q) {

    var deferred = $q.defer();
    var bettors = {'blue': [],
                   'purple': [],
                   'top': []};

    $http.get('/api/bettors')
    .success(function(result) {
      if (result.bets.length > 0) {
        result.bets.forEach(function(bet) {
          if (bet.kind === 'game') {
            bettors.blue = bet.blue;
            bettors.purple = bet.purple;
          }
        });
      }
      bettors.top = result.top;
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
