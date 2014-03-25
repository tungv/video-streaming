angular.module 'BookStore'
.factory 'User', ($resource)->
    $resource "#{window.api_host}/api/users/:id", {
      id: '@id'
    }, {
      update:
        method: 'PUT'
        params: {}
      get:
        method: 'GET'
        params: {
          id: 'me'
        }
      register:
        method: 'POST'
        params: {
          hashed: 'true'
        }
    }