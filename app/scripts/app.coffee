angular.module 'BookStore', ['ngResource', 'ngRoute', 'ngCookies', 'ngSanitize']
.config class AppConfig
    @$inject = ['$routeProvider', '$locationProvider', '$httpProvider']
    constructor: ($routeProvider, $locationProvider, $httpProvider)->
      $routeProvider
      .when('/', {
            controller: 'HomeCtrl as home'
            templateUrl: '/partials/home.html'
          })
      .when('/login', {
            controller: 'LoginCtrl as login'
            templateUrl: '/partials/login.html'
          })
      .when('/signup', {
            controller: 'SignUpCtrl as signup'
            templateUrl: '/partials/signup.html'
          })
      .when('/books/:bookId', {
            controller: 'BookDetailCtrl as detail'
            templateUrl: '/partials/book-detail.html'
          })
      .when('/books', {
            controller: 'BookIndexCtrl as index'
            templateUrl: '/partials/book-index.html'
          })
      .when('/error/404', {
            templateUrl: '/partials/error-404.html'
          })
      .otherwise({
            redirectTo: '/error/404'
          })

      $locationProvider.html5Mode on

      $httpProvider.interceptors.push [
        '$q', '$location', '$rootScope'
        ($q, $location, $rootScope)->
          responseError: (resp)->
            if resp.status is 401 or resp.status is 403
              $location.path '/login'

            return $q.reject resp

          request: (config)->
            #console.log('request interceptor', config)
            apiPath = "#{window.api_host}/api/"
            if $rootScope.user?.email? and config.url.indexOf(apiPath) == 0
              config.headers['X-AUTH-USERNAME'] = $rootScope.user.email
              config.headers['X-AUTH-TOKEN'] = $rootScope.user.password
              config.headers['X-AUTH-HASHED'] = 'true'
              console.log 'Append header for api request'

            return config
      ]