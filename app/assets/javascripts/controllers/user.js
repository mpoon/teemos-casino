angular.module('salty-spork').controller('UserCtrl',
  ['$scope', '$http', 'user', 'pusher', function UserCtrl($scope, $http, user, pusher) {
    user.getStatus.then(function(status) {
      $scope.loggedIn = status.loggedIn;
      $scope.user = status.user;
    });

    pusher.on("wallet_update", function(msg) {
      $scope.$apply(function() {
        $scope.user.wallet = msg.wallet;
        if (msg.message) {
          $.notify.alert(msg.message);
        }
        console.log("Wallet update: ", msg);
      });
    });
  }]);
