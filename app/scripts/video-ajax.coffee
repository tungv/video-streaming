videos = [
  {
    name: "Music Video", path: 'mv.webm'
  }
]

createSrc = (array)->
  (window.URL || window.webkitURL).createObjectURL(new Blob(array))

$ ()->
  $video = $('video')

  $('#play').on 'click', ()->
    start = 0
    video = videos[0]
    promise = $.ajax {
      url: "/video/#{video.path}?start=#{start}"
      #type: 'ArrayBuffer'
    }

    promise.success (data)->
      $video.attr 'src', createSrc(data)

    promise.fail (err)->
      console.error err

