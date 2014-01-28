angular.module('filters', [])
.filter('time', function() {
  var pad = function(n, width, z) {
    z = z || '0';
    n = n + '';
    return n.length >= width ? n : new Array(width - n.length + 1).join(z) + n;
  };

  return function(input) {
    var number = parseInt(input, 10);
    return Math.floor(number / 60) + ':' + pad(number % 60, 2);
  };
});
