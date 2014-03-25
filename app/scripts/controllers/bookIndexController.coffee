angular.module 'BookStore'
  .controller 'BookIndexCtrl', class BookIndexCtrl
    constructor: (@Book, @Pagination)->
      @update({skip: 0, limit: 12})

    update: ({skip, limit}={})->
      query = @query or ''
      sort = @sort or 'price'

      @books = @Book.query {
        limit : limit or 12
        skip : skip or 0
        search: query if query.length
        sort
      }, (data, headers)=>
        data.$paging = @Pagination data, headers




