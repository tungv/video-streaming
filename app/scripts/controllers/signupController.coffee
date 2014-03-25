angular.module 'BookStore'
  .controller 'SignUpCtrl', class SignUpCtrl
    @$inject = ['$scope', 'Auth', 'User']
    constructor: (@scope, @Auth, @User)->

    submit: (form)->
      @scope.$broadcast 'autofill:update'

      return unless form.$valid

      password = md5 @password

      user = new @User {
        email: @email
        password
        displayName: @displayName
      }

      user.$register()
        .then (resp)->
          @Auth.login @email,password
        .catch (resp)=>
          errs = resp.data
          @errors = {}

          angular.forEach errs, (err, field) =>
            form[field].$setValidity 'mongoose', false
            @errors[field] = err.type