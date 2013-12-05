angular.module('salty-spork').factory('betMode',
  ['$http', '$q', function($http, $q) {

    var deferred = $q.defer();
    var status = {};

    $http.get('/api/bet')
    .success(function(bet) {
      status.mode = bet.mode;
      status.gameId = bet.game_id;
      status.amount = bet.amount;
      status.team = bet.team;
      status.expires = bet.expires;

      mixpanel.track(
        'betstatus',
        { 'bet_mode': bet.mode,
          'game_id': bet.game_id,
          'amount': bet.amount,
          'team': bet.team,
          'expires': bet.expires });

      deferred.resolve(status);
    }).error(function(data, status_code) {
      status.mode = "closed";

      status.gameId = 0;
      status.amount = 0;
      status.team = "None";
      status.expires = 0;

      mixpanel.track(
        'betstatus_error',
        { 'status_code': status_code });

      deferred.resolve(status);
    });

    return {
      getStatus: function() {
        return deferred.promise;
      }
    };
  }]);
