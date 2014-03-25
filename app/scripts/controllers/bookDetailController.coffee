angular.module 'BookStore'
  .controller 'BookDetailCtrl', class BookDetailCtrl
    @$inject = ['$routeParams', 'Book', '$location']
    constructor: ($routeParams, @Book, @location)->
      id = $routeParams.bookId
      @book = Book.get {id}


    update: ->
      @book.$update()
        .then ()-> alert 'Updated'
        .catch (resp)->
          errors = resp.data
          console.warn errors

    remove: ->
      if confirm 'Do you want to delete this book?\n\nTHIS CANNOT BE UNDONE'
        @book.$remove().then ()=> @location.path '/books'