angular.module 'BookStore'
  .directive 'autofillEnabled', ->
    require: 'ngModel'
    link: (scope, elem, attr, ngModel)->
      scope.$on 'autofill:update', -> ngModel.$setViewValue elem.val() 