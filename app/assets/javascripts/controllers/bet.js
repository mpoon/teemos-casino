/*global mixpanel,machina*/
angular.module('salty-spork').controller('BettingCtrl',
  ['$scope', '$resource', '$timeout', 'user', 'betMode', 'bettingFsm',
  function BettingCtrl($scope, $resource, $timeout, user, betMode, bettingFsm) {

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
  $scope.wallet = 0;
  $scope.betMode = "closed";

  var BetOdds = {
    reset: function() {
      $scope.odds = {
        blue: {
          mult: 0,
          pool: 0
        },
        purple: {
          mult: 0,
          pool: 0
        }
      };
    },
    update: function(odds) {
      $scope.odds = odds;
    }
  };
  BetOdds.reset();

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
        // Allow the placeholder on the input to work
        // by setting undefined instead of 0
        amount: undefined,
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

  // Validate bet model on change
  $scope.betAmountChange = function() {
    var num = parseInt($scope.bet.amount, 10);

    if ($scope.bet.amount && _.isNaN(num)) {
      // If not undefined (user input)
      $scope.bet.amount = 0;
    } else if (num > $scope.wallet) {
      $scope.bet.amount = $scope.wallet;
    } else {
      $scope.bet.amount = num;
    }
  };

  var countdownInterval;
  $scope.countdown = 0;
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
      BetOdds.reset();

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

  bettingFsm.on("bet.odds", function(odds) {
    $scope.$apply(function() {
      BetOdds.update(odds);
    });
  });

  user.on('wallet', function(amount) {
    $scope.$apply(function() {
      $scope.wallet = amount;
    });
  });
}]);
