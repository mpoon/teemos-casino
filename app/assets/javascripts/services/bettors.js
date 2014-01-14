angular.module('salty-spork').factory('bettors',
  ['$http', '$q', function($http, $q) {

    var deferred = $q.defer();
    var bettors = {'blue': [],
                   'purple': [],
                   'top': []};

    $http.get('/api/bettors')
    .success(function(result) {
      bettors.blue = result.blue;
      bettors.purple = result.purple;
      bettors.top = result.top;
      deferred.resolve(bettors);
    }).error(function(data, status_code) {
      deferred.resolve(bettors);
    });

    return {
      getStatus: function() {
        return deferred.promise;
      }
    };
  }]);
