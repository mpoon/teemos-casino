/*global machina, mixpanel*/
angular.module('salty-spork').factory('bettingFsm',
  ['$resource', '$q', 'pusher', 'betMode', function($resource, $q, pusher, betMode) {

  var Bet = $resource('/api/bet');

  var BettingFsm;

  BettingFsm = machina.Fsm.extend({
    currentGameId: 0,
    currentBetExpires: 0,
    initialize: function() {
        // do stuff here if you want to perform more setup work
        // this executes prior to any state transitions or handler invocations
    },
    emit: function() {
      // Ensure we aren't in an $apply/$digest execution context
      // since .emit() is sync (boo!)
      var args = arguments;
      _.defer(function(self) {
        machina.Fsm.prototype.emit.apply(self, args);
      }, this);
    },
    initialState: 'closed',
    states: {
      closed: {
        _onEnter: function() {
          console.info("[FSM] Betting closed: gameId=" + this.currentGameId);
          this.emit('betting.closed', {gameId: this.currentGameId});
          this.currentGameId = 0;
          this.currentBetExpires = 0;
        },
        placeBet: function() {
          throw new Error("Betting is closed!");
        },
        "game.start": function(id, expires) {
          if (!id) {
            throw new Error("Missing game id");
          }

          if (!expires) {
            throw new Error("Missing expire time");
          }

          this.currentGameId = id;
          this.currentBetExpires = expires;
          this.transition('open');
        }
      },
      open: {
        _onEnter: function() {
          var self = this;
          console.info("[FSM] Betting open: gameId=" + this.currentGameId +
                       " expire=" + this.currentBetExpires);
          this.emit('betting.open', {gameId: this.currentGameId, expires: this.currentBetExpires});

          var gameId = self.currentGameId;
          setTimeout(function() {
            self.handle("game.expired", gameId);
          }, this.currentBetExpires - Date.now());
        },
        "game.end": function(id) {
          if (!id) {
            throw new Error("Missing game id");
          }

          if (id !== this.currentGameId) {
            console.error("[FSM] Attempt to end game with unknown game_id (" + id + ")." +
                          " Transitioning anyway.");
          }
          this.transition('closed');
        },
        "game.expired": function(id) {
          if (id !== this.currentGameId) {
            console.error("[FSM] Attempt to expire game with unknown game_id (" + id + ")." +
                          " Transitioning anyway.");
          }
          console.log("Betting period expired!");
          this.transition('closed');
        },
        "placeBet": function(amount, team) {
          var bet = new Bet(),
              self = this;

          if (!amount || !team) {
            throw new Error("Missing amount or team");
          }

          mixpanel.track("place_bet", {amount: amount, team: team, game_id: this.currentGameId});

          bet.$save({ game_id: this.currentGameId, amount: amount, team: team})
          .then(function() {
            mixpanel.track('bet_placed', {amount: amount, team: team, game_id: this.currentGameId});
            self.emit('bet.placed', {
              gameId: self.currentGameId,
              amount: amount,
              team: team
            });
          },
          function(err) {
            // TODO: We probably want to distinguish between real errors
            // and conflict errors (already have bet for this match)
            mixpanel.track('place_bet_error', { 'error': err });
            self.emit('bet.error', { error: err });
          });
        }
      },
      placed: {
        // Bets locked in; TODO
      }
    }
  });

  var bettingFsm = new BettingFsm();

  pusher.on("game_start", function(msg) {
    console.log("New game: " + msg.game_id);
    console.log("Betting expires: " + msg.expires);
    mixpanel.track('receive_game_start', {game_id: msg.game_id, expires: msg.expires});
    bettingFsm.handle('game.start', msg.game_id, msg.expires);
  });

  pusher.on("game_end", function(msg) {
    console.log("End game: " + msg.game_id);
    mixpanel.track('receive_game_end', {game_id: msg.game_id});
    bettingFsm.handle('game.end', msg.game_id);
  });

  betMode.getStatus().then(function(status) {
    if (status.mode === "closed") {
      return;
    }

    // If we're already engaged in a game, get our FSM
    // into the right place and fake events.
    // There's probably a cleaner way...
    bettingFsm.handle("game.start", status.gameId, Date.parse(status.expires));

    if (status.mode === "placed") {
      bettingFsm.emit("bet.placed", {
        gameId: status.gameId,
        amount: status.amount || 0,
        team: status.team,
        expires: status.expires
      });
    }
  });

  return bettingFsm;
}]);
