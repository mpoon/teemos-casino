angular.module('teemos-casino').controller('AboutCtrl',
  ['$scope', '$http', '$modal',
  function ($scope, $http, $modal) {
	$scope.open = function() {
		var modalInstance = $modal.open({
			templateUrl: 'aboutModalContent.html',
			controller: ModalInstanceCtrl
		});
	};
  }]);

var ModalInstanceCtrl = function ($scope, $modalInstance) {
	$scope.ok = function() {
		$modalInstance.close();
	};
};

angular.module('teemos-casino').controller('CarouselCtrl',
  ['$scope', '$http',
  function ($scope, $http) {
	$scope.myInteval = -1;
	var slides = $scope.slides = [];
	slides.push(
		{image: 'http://placekitten.com/800/600'},
		{image: 'http://placekitten.com/799/600'},
		{image: 'http://placekitten.com/801/600'}
	);

}]);
