angular.module('teemos-casino').controller('BettorsCtrl',
  ['$scope', 'pusher', 'bettors', 'Constants', function ($scope, pusher, bettors, Constants) {

    $scope.seasonTop = [];
    $scope.purpleLiveBets = [];
    $scope.blueLiveBets = [];
    $scope.purpleLiveSideBets = [];
    $scope.blueLiveSideBets = [];

    bettors.getStatus().then(function(status) {
      $scope.purpleLiveBets = status.purple;
      $scope.blueLiveBets = status.blue;
      $scope.seasonTop = status.top;
    });

    pusher.on('bettor', function(msg) {
      if(msg.kind === 'game') {
        if(msg.team === 'purple') {
          $scope.purpleLiveBets.push({'name': msg.name, 'amount': msg.amount});
        }
        if(msg.team === 'blue') {
          $scope.blueLiveBets.push({'name': msg.name, 'amount': msg.amount});
        }
      }
      else {
        if(msg.team === 'purple') {
          $scope.purpleLiveSideBets.push({'name': msg.name, 'amount': msg.amount});
        }
        if(msg.team === 'blue') {
          $scope.blueLiveSideBets.push({'name': msg.name, 'amount': msg.amount});
        }
      }
    });

    pusher.on('season_top', function(msg) {
      $scope.seasonTop = msg.top;
    });

    pusher.on('bet_close', function(msg) {
      if(msg.kind === 'game') {
        $scope.purpleLiveBets = [];
        $scope.blueLiveBets = [];
      }
      else {
        $scope.purpleLiveSideBets = [];
        $scope.blueLiveSideBets = [];
      }
    });
  }]);
