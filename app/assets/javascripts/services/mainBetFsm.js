/*global machina, mixpanel*/
angular.module('teemos-casino').factory('mainBetFsm',
  ['$resource', '$q', 'pusher', 'betMode', function($resource, $q, pusher, betMode) {

  var Bet = $resource('/api/bet');

  var MainBetFsm = machina.Fsm.extend({
    currentState: {
      mode: null,
      gameId: null,
      betId: null,
      expires: null,
      team: null,
      amount: null,
      kind: null,
      odds: null,
      result: null
    },
    emit: function() {
      // Ensure we aren't in an $apply/$digest execution context
      // since .emit() is sync (boo!)
      var args = arguments;
      _.defer(function(self) {
        machina.Fsm.prototype.emit.apply(self, args);
      }, this);
    },
    initialState: 'uninitialized',
    states: {
      uninitialized: {
        _onEnter: function() {
          console.log('[MainBetFsm] Enter state: uninitialized');
          this.currentState.mode = null;
          this.currentState.gameId = null;
          this.currentState.betId = null;
          this.currentState.expires = null;
          this.currentState.team = null;
          this.currentState.amount = null;
          this.currentState.kind = null;
          this.currentState.odds = null;
          this.currentState.result = null;
        },
        openBet: function(state) {
          console.log('[MainBetFsm] From state: uninitialized transition openBet');
          this.currentState.gameId = state.gameId;
          this.currentState.betId = state.betId;
          this.currentState.kind = state.kind;
          this.currentState.expires = state.expires;
          this.currentState.mode = 'open';

          this.transition('open');
        },
        initialize: function(state) {
          console.log('[MainBetFsm] From state: uninitialized transition initialize');
          this.currentState.mode = state.mode;
          this.currentState.gameId = state.gameId;
          this.currentState.betId = state.betId;
          this.currentState.expires = state.expires;
          this.currentState.team = state.team;
          this.currentState.amount = state.amount;
          this.currentState.kind = state.kind;
          this.currentState.odds = state.odds;
          this.currentState.result = state.result;

          if (this.currentState.mode === null) {
            this.transition('uninitialized');
          }
          else if (this.currentState.mode === 'placed') {
            // REWRITE EMITS
            this.emit('bet.placed', {
              gameId: this.currentState.gameId,
              amount: this.currentState.amount || 0,
              team: this.currentState.team,
              expires: this.currentState.expires
            });
            this.transition('placed');
          }
          else if (this.currentState.mode === 'open') {
            this.transition('open');
          }
          else {
            this.transition('closed');
          }
        }
      },
      closed: {
        _onEnter: function() {
          console.log('[MainBetFsm] Enter state: closed');
          this.emit('betting.closed', {
            gameId: this.currentState.gameId
          });
        },
        betClose: function() {
          console.log('[MainBetFsm] From state: closed transition betClose');
          this.transition('uninitialized');
        },
        betOdds: function(odds) {
          console.log('[MainBetFsm] From state: closed transition betOdds');
          this.currentState.odds = odds;
          this.emit('bet.odds', odds);
        }
      },
      open: {
        _onEnter: function() {
          console.log('[MainBetFsm] Enter state: open');

          // REWRITE EMIT
          this.emit('betting.open', {
            gameId: this.currentState.gameId,
            expires: this.currentState.expires
          });

          var self = this;
          setTimeout(function() {
            self.handle('betExpire');
          }, this.currentState.expires - Date.now());
        },
        placeBet: function(amount, team) {
          console.log('[MainBetFsm] From state: open transition placeBet');
          var bet = new Bet(),
              self = this;

          bet.$save({
            game_id: this.currentState.gameId,
            amount: amount,
            team: team,
            bet_id: this.currentState.betId,
            kind: this.currentState.kind
          }).then(function() {
            self.currentState.amount = amount;
            self.currentState.team = team;
            self.currentState.mode = 'placed';
            // REWRITE EMITS
            self.emit('bet.placed', {
              gameId: self.currentState.gameId,
              amount: self.currentState.amount,
              team: self.currentState.team
            })
            self.transition('placed');
          }, function(error) {

          });
        },
        betExpire: function() {
          console.log('[MainBetFsm] From state: open transition betExpire');
          this.currentState.mode = 'closed';
          this.transition('closed');
        },
        betOdds: function(odds) {
          console.log('[MainBetFsm] From state: open transition betOdds');
          this.currentState.odds = odds;
          //REWRITE EMIT
          this.emit('bet.odds', odds);
        }
      },
      placed: {
        _onEnter: function() {
          console.log('[MainBetFsm] Enter state: placed');
        },
        betClose: function() {
          console.log('[MainBetFsm] From state: placed transition betClose');
          this.transition('uninitialized');
        },
        betOdds: function(odds) {
          console.log('[MainBetFsm] From state: placed transition betOdds');
          this.currentState.odds = odds;
          //REWRITE EMIT
          this.emit('bet.odds', odds);
        }
      }
    }
  });

  var mainBetFsm = new MainBetFsm();

  pusher.on('bet_open', function(msg) {
    console.log('bet open ');
    console.log(msg);
    if (msg.kind === 'game') {
      mainBetFsm.handle('openBet', msg);
    }
  });

  pusher.on('bet_close', function(msg) {
    console.log('bet closed');
    console.log(msg);
    if (msg.kind === 'game') {
      mainBetFsm.handle('betClose', msg);
    }
  });

  pusher.on('bet_update', function(msg) {
    console.log('bet update');
    console.log(msg);
    mainBetFsm.handle('betOdds', msg.odds);
  });

  betMode.get().then(function(bets) {
    bets.forEach(function(bet) {
      if (bet.kind === 'game' || bet.kind === null) {
        mainBetFsm.handle('initialize', bet);
      }
    });
  });

  return mainBetFsm;
}]);
