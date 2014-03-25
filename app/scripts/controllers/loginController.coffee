angular.module 'BookStore'
.controller 'LoginCtrl', class LoginCtrl
    @$inject = ['$scope', 'Auth']
    constructor: (@scope, @Auth)->
      @submitting = false

    login: (form) ->
      return if @submitting

      @scope.$broadcast 'autofill:update'

      valid = form.$valid
      return unless valid

      @submitting = true

      password = md5 @password
      @password = 'dont do it'

      @Auth.login @email, password, => @submitting = false

