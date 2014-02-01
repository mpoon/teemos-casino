angular.module('salty-spork').controller('BettorStatusCtrl',
  ['$scope', 'pusher', 'bettors', function BettorStatusCtrl($scope, pusher, bettors) {

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
      if(msg.team === 'purple') {
        $scope.purpleLiveBets.push({'name': msg.name, 'amount': msg.amount});
      }
      if(msg.team === 'blue') {
        $scope.blueLiveBets.push({'name': msg.name, 'amount': msg.amount});
      }
    });

    pusher.on('season_top', function(msg) {
      $scope.seasonTop = msg.top;
    });

    pusher.on('game_end', function() {
      $scope.purpleLiveBets = [];
      $scope.blueLiveBets = [];
    });
  }]);
