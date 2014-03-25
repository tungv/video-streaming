angular.module 'BookStore'
.directive 'mongooseError', ->
    require: 'ngModel'
    restrict: 'A'
    link: (scope, elem, attr, ngModel)->
      elem.on 'keydown', -> ngModel.$setValidity 'mongoose', true