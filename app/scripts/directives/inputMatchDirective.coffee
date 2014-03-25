angular.module 'BookStore'
.directive 'inputMatch', ($parse)->
    require: '?ngModel'
    restrict: 'A'
    link: (scope, elem, attr, ngModel)->
      return unless ngModel

      firstPasswordGetter = $parse attr['inputMatch']

      validator = (value)->
        password = firstPasswordGetter scope
        ngModel.$setValidity 'match', password is value
        return value

      ngModel.$parsers.unshift validator
      ngModel.$formatters.push validator
      attr.$observe 'inputMatch', -> validator ngModel.$viewValue