/*global mixpanel,machina*/
angular.module('salty-spork').controller('BettingCtrl',
  ['$scope', '$resource', '$timeout', 'user', 'pusher', 'betMode', 'bettingFsm',
  function BettingCtrl($scope, $resource, $timeout, user, pusher, betMode, bettingFsm) {

  var teams = {
    "blue": "Blue",
    "purple": "Purple"
  };

  $scope.showBetControls = false;
  user.getStatus.then(function(status) {
    if (status.loggedIn) {
      $scope.showBetControls = true;
    }
  });

  $scope.currentGameId = 0;
  $scope.betMode = "closed";
  $scope.blueOdds = 0;
  $scope.purpleOdds = 0;

  var Bet = {
    init: function() {
      $scope.bet = {};
      this.reset();
    },
    placed: function(betEvent) {
      $scope.bet = {
        team: teams[betEvent.team],
        amount: betEvent.amount,
        gameId: betEvent.gameId,
        status: 'placed'
      };
    },
    reset: function() {
      $scope.bet = {
        team: null,
        amount: 0,
        gameId: 0,
        status: null
      };
    }
  };

  Bet.init();

  $scope.makeBet = function(amount, team) {
    if ($scope.betMode !== "open") {
      $.notify.error("Betting is closed for the current game");
      return;
    }

    mixpanel.track(
      "place_bet",
      { 'amount': amount,
        'team': team});

    bettingFsm.handle('placeBet', amount, team);
    // TODO: show loading spinner
  };

  pusher.on("bet_odds", function(msg) {
    console.log('bet odds: ' + msg)
    $scope.$apply(function() {
      $scope.blueOdds = msg.blue;
      $scope.purpleOdds = msg.purple;
      console.log("Bet odds update: blue " + msg.blue + " purple " + msg.purple);
    });
  });

  var countdownInterval;
  var updateCountdown = function(expires) {
    var now = expires - Date.now();
    if (now > 0) {
      $scope.countdown = Math.floor(now / 1000);
    } else {
      clearInterval(countdownInterval);
    }
    $scope.$digest();
  };

  bettingFsm.on('betting.open', function(event) {
    $scope.$apply(function() {
      console.debug("got betting open msg from fsm:", event);
      $scope.betMode = "open";

      clearInterval(countdownInterval);
      countdownInterval = setInterval(_.bind(updateCountdown, null, event.expires), 100);
      Bet.reset();
    });
  });

  bettingFsm.on('betting.closed', function(event) {
    $scope.$apply(function() {
      console.debug("got betting closed msg from fsm:", event);
      $scope.betMode = "closed";
      Bet.reset();
    });
  });

  bettingFsm.on('bet.placed', function(betEvent) {
    $scope.$apply(function() {
      $.notify.success("Placed a bet for " + betEvent.amount + "!");
      console.debug("we placed a bet wooo!", betEvent);
      mixpanel.track(
        'bet_placed',
        { 'amount': betEvent.amount,
          'team': betEvent.team,
          'game_id': betEvent.gameId});
      // The FSM can still accept bets, but we need to work out
      // the UI
      $scope.betMode = "closed";
      Bet.placed(betEvent);
    });
  });

  bettingFsm.on('bet.error', function(event) {
    $scope.$apply(function() {
      $.notify.error("Sorry, we had an error placing your bet");
      console.debug("we got a betting error", event);
    });
  });
}]);
