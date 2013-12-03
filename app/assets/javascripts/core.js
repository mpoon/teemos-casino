angular.module('salty-spork', [
  'ngResource',
  'ngRoute',
]).config(["$routeProvider", function($routeProvider) {
  $routeProvider
  .when('/', {
    templateUrl: 'assets/bet.html',
    controller: 'BettingCtrl'
  })
  .otherwise({
    redirectTo: '/'
  });
}])
.config(["$locationProvider", function($locationProvider) {
  $locationProvider.html5Mode(true);
}]);
