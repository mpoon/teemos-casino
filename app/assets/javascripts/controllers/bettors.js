angular.module('teemos-casino').controller('BettorsCtrl',
  ['$scope', 'pusher', 'bettors', function ($scope, pusher, bettors) {

    $scope.displayBetType = 'main';
    $scope.seasonTop = [];
    $scope.purpleLiveBets = [];
    $scope.blueLiveBets = [];
    $scope.purpleLiveSideBets = [];
    $scope.blueLiveSideBets = [];

    bettors.getStatus().then(function(status) {
      status.bets.forEach(function(bet) {
        if (bet.kind === 'game') {
          $scope.purpleLiveBets = bet.purple;
          $scope.blueLiveBets = bet.blue;
        } else {
          $scope.purpleLiveSideBets = bet.purple;
          $scope.blueLiveSideBets = bet.blue;
        }
      });
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
