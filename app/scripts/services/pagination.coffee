angular.module 'BookStore'
.factory 'Pagination', ->
    parseLink = (data, header, skip='skip', limit='limit')->
      links = header.split(', ')
      paging = {}
      for link in links
        ## handle rel name
        parts = link.split('; rel=')
        rel = parts[1].split('"')[1]

        ## handle rel link
        regex = new RegExp "#{skip}=(\\d+)"
        skipVal = Number parts[0].match(regex)?[1]

        regex = new RegExp "#{limit}=(\\d+)"
        limitVal = Number parts[0].match(regex)?[1]

        ## merge
        paging[rel] = {skip: skipVal, limit: limitVal}


      total = paging.last.skip + limitVal
      pages = Math.ceil total / limitVal
      total = data.length if pages is 1
      currentPage = 1 + Math.ceil paging.self.skip / limitVal
      from = paging.self.skip + 1
      to = Math.min total, from + limitVal - 1

      visiblePages = ({page: p, skip: limitVal * (p-1), limit: limitVal, current: p is currentPage} for p in [1..pages])


      return angular.extend paging, {total, pages, currentPage, from, to, visiblePages}

    (data, headerGetter)->
      linkHeader = headerGetter 'link'
      return {} unless linkHeader?.length

      parseLink data, linkHeader