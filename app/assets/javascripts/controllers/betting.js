angular.module('teemos-casino').controller('BettingCtrl',
  ['$scope', '$resource', '$timeout', 'user', 'betMode', 'mainBetFsm', 'sideBetFsm',
  function ($scope, $resource, $timeout, user, betMode, mainBetFsm, sideBetFsm) {

  var teams = {
    'blue': 'Blue',
    'purple': 'Purple'
  };

  $scope.showBetControls = false;
  user.getStatus.then(function(status) {
    if (status.loggedIn) {
      $scope.showBetControls = true;
    }
  });

  $scope.currentGameId = 0;
  $scope.wallet = 0;
  $scope.betMode = {
    'main': 'closed',
    'side': 'closed'
  };
  $scope.displayBetType = 'main';
  $scope.odds = {
    'main': {
      blue: {
        mult: 0,
        pool: 0
      },
      purple: {
        mult: 0,
        pool: 0
      }
    },
    'side': {
      blue: {
        mult: 0,
        pool: 0
      },
      purple: {
        mult: 0,
        pool: 0
      }
    }
  };
  $scope.bet = {
    'main': {},
    'side': {}
  };

  var BetOdds = {
    reset: function(kind) {
      if (kind === 'game') {
        $scope.odds.main = {
          blue: {
            mult: 0,
            pool: 0
          },
          purple: {
            mult: 0,
            pool: 0
          }
        };
      } else {
        $scope.odds.side = {
          blue: {
            mult: 0,
            pool: 0
          },
          purple: {
            mult: 0,
            pool: 0
          }
        };
      }
    },
    update: function(kind, odds) {
      if (kind === 'game') {
        $scope.odds.main = odds;
      } else {
        $scope.odds.side = odds;
      }
    }
  };
  BetOdds.reset('game');
  BetOdds.reset('side');

  var Bet = {
    init: function(kind) {
      if (kind === 'game') {
        $scope.bet.main = {};
        this.reset(kind);
      } else {
        $scope.bet.side = {};
        this.reset(kind);
      }
    },
    placed: function(kind, betEvent) {
      if (kind === 'game') {
        $scope.bet.main = {
          team: teams[betEvent.team],
          amount: betEvent.amount,
          gameId: betEvent.gameId,
          status: 'placed'
        };
      } else {
        $scope.bet.side = {
          team: teams[betEvent.team],
          amount: betEvent.amount,
          gameId: betEvent.gameId,
          status: 'placed'
        };
      }
    },
    reset: function(kind) {
      if (kind === 'game') {
        $scope.bet.main = {
          team: null,
          // Allow the placeholder on the input to work
          // by setting undefined instead of 0
          amount: undefined,
          gameId: 0,
          status: null
        };
      } else {
        $scope.bet.side = {
          team: null,
          // Allow the placeholder on the input to work
          // by setting undefined instead of 0
          amount: undefined,
          gameId: 0,
          status: null
        };
      }
    }
  };

  Bet.init('game');
  Bet.init('side');

  $scope.makeBet = function(kind, amount, team) {
    if (kind === 'game') {
      if ($scope.betMode.main !== 'open') {
        $.speechBubble.write('Betting is closed for the current game');
        return;
      }

      mainBetFsm.handle('placeBet', amount, team);
    } else {
      if ($scope.betMode.side !== 'open') {
        $.speechBubble.write('Betting is closed for the current game');
        return;
      }

      sideBetFsm.handle('placeBet', amount, team);
    }
    // TODO: show loading spinner
  };

  // Validate bet model on change
  $scope.betAmountChange = function(kind) {
    var num;
    if (kind === 'game') {
      num = parseInt($scope.bet.main.amount, 10);

      if ($scope.bet.main.amount && _.isNaN(num)) {
        // If not undefined (user input)
        $scope.bet.main.amount = 0;
      } else if (num > $scope.wallet) {
        $scope.bet.main.amount = $scope.wallet;
      } else {
        $scope.bet.main.amount = num;
      }
    } else {
      num = parseInt($scope.bet.side.amount, 10);

      if ($scope.bet.side.amount && _.isNaN(num)) {
        // If not undefined (user input)
        $scope.bet.side.amount = 0;
      } else if (num > $scope.wallet) {
        $scope.bet.side.amount = $scope.wallet;
      } else {
        $scope.bet.side.amount = num;
      }
    }
  };

  var mainCountdownInterval;
  var sideCountdownInterval;
  $scope.countdown = {
    'main': 0,
    'side': 0
  };
  var updateCountdown = function(kind, expires) {
    var now;
    if (kind === 'game') {
      now = expires - Date.now();
      if (now > 0) {
        $scope.countdown.main = Math.floor(now / 1000);
      } else {
        clearInterval(mainCountdownInterval);
      }
      $scope.$digest();
    } else {
      now = expires - Date.now();
      if (now > 0) {
        $scope.countdown.side = Math.floor(now / 1000);
      } else {
        clearInterval(sideCountdownInterval);
      }
      $scope.$digest();
    }
  };

  mainBetFsm.on('betting.open', function(event) {
    $scope.$apply(function() {
      console.debug('got betting open msg from fsm:', event);
      $scope.betMode.main = 'open';
      BetOdds.reset('game');

      clearInterval(mainCountdownInterval);
      mainCountdownInterval = setInterval(_.bind(updateCountdown, null, 'game', event.expires), 100);
      Bet.reset('game');
    });
  });

  mainBetFsm.on('betting.closed', function(event) {
    $scope.$apply(function() {
      console.debug('got betting closed msg from fsm:', event);
      $scope.betMode.main = 'closed';
    });
  });

  mainBetFsm.on('bet.placed', function(betEvent) {
    $scope.$apply(function() {
      $.speechBubble.write('Placed a bet for ' + betEvent.amount + '!');
      console.debug('we placed a bet wooo!', betEvent);
      // The FSM can still accept bets, but we need to work out
      // the UI
      $scope.betMode.main = 'closed';
      Bet.placed('game', betEvent);
    });
  });

  mainBetFsm.on('bet.error', function(event) {
    $scope.$apply(function() {
      $.speechBubble.write('Sorry, we had an error placing your bet');
      console.debug('we got a betting error', event);
    });
  });

  mainBetFsm.on('bet.odds', function(odds) {
    $scope.$apply(function() {
      BetOdds.update('game', odds);
    });
  });

  sideBetFsm.on('betting.open', function(event) {
    $scope.$apply(function() {
      console.debug('got betting open msg from fsm:', event);
      $scope.betMode.side = 'open';
      BetOdds.reset('side');

      clearInterval(sideCountdownInterval);
      sideCountdownInterval = setInterval(_.bind(updateCountdown, null, 'side', event.expires), 100);
      Bet.reset('side');
    });
  });

  sideBetFsm.on('betting.closed', function(event) {
    $scope.$apply(function() {
      console.debug('got betting closed msg from fsm:', event);
      $scope.betMode.side = 'closed';
    });
  });

  sideBetFsm.on('bet.placed', function(betEvent) {
    $scope.$apply(function() {
      $.speechBubble.write('Placed a bet for ' + betEvent.amount + '!');
      console.debug('we placed a bet wooo!', betEvent);
      // The FSM can still accept bets, but we need to work out
      // the UI
      $scope.betMode.side = 'closed';
      Bet.placed('side', betEvent);
    });
  });

  sideBetFsm.on('bet.error', function(event) {
    $scope.$apply(function() {
      $.speechBubble.write('Sorry, we had an error placing your bet');
      console.debug('we got a betting error', event);
    });
  });

  sideBetFsm.on('bet.odds', function(odds) {
    $scope.$apply(function() {
      BetOdds.update('side', odds);
    });
  });

  user.on('wallet', function(amount) {
    $scope.$apply(function() {
      $scope.wallet = amount;
    });
  });
}]);
