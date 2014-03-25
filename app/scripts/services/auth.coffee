angular.module 'BookStore'
  .service 'Auth', class Auth
    @$inject = ['$location', '$rootScope', '$cookieStore', '$http']
    constructor: ($location, $rootScope, $cookieStore, $http)->

      $rootScope.user = $cookieStore.get('user') or {}

      @login = (email, password, callback=angular.noop)->
        $http.post "#{window.api_host}/api/login?hashed=true", {email, password}
          .then (resp)->
            user = angular.extend resp.data, {password}
            $rootScope.user = user
            $cookieStore.put 'user', user
            callback null, $rootScope.user

            $location.path('/books')
          , (err)->
            $cookieStore.remove 'user'
            callback err

      @logout = (callback=angular.noop)->
        $http.post "#{window.api_host}/api/logout"
          .then ->
            $rootScope.user = {}
            $cookieStore.remove 'user'
            $location.path '/'
            callback()

      @isLoggedIn = -> !!$rootScope.user?.email