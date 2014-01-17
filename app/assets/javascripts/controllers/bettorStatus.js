angular.module('salty-spork').controller('BettorStatusCtrl',
  ['$scope', 'pusher', 'bettors', function BettorStatusCtrl($scope, pusher, bettors) {

    $scope.seasonTop = [];
    $scope.purpleLiveBets = [];
    $scope.blueLiveBets = [];

    bettors.getStatus().then(function(status) {
      $scope.purpleLiveBets = status.purple;
      $scope.blueLiveBets = status.blue;
      $scope.seasonTop = status.top;
    });

    pusher.on("bettor", function(msg) {
      if(msg.team === 'purple') {
        $scope.purpleLiveBets.push({'name': msg.name, 'amount': msg.amount});
      }
      if(msg.team === 'blue') {
        $scope.blueLiveBets.push({'name': msg.name, 'amount': msg.amount});
      }
    });

    pusher.on("game_end", function(msg) {
      $scope.purpleLiveBets = [];
      $scope.blueLiveBets = [];
      $scope.seasonTop = msg.top
    });
  }]);
