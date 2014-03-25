angular.module 'BookStore'
  .factory 'Book', ($resource, $q, $location)->
    $resource "#{window.api_host}/api/books/:id", {
      id: '@id'
    }, {
      update:
        method: 'PUT'
        params: {}
      get:
        method: 'GET'
        interceptor:
          responseError: (resp)->
            if resp.status is 404
              $location.path '/error/404'

            $q.reject resp
    }


