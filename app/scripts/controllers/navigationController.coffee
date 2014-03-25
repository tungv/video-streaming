angular.module 'BookStore'
  .controller 'NavigationCtrl', class NavigationCtrl
    @$inject = ['Auth']
    constructor: (@Auth)->

    logout: ->
      @Auth.logout()