angular.module 'VideoApp'
  .controller 'VideoCtrl', class VideoCtrl
    constructor: (@Video)->
#      Video.on 'stream', (stream) =>
#        Video.download stream, (err, src) =>
#          $('video').attr('src', src)

      Video.on 'open', () =>
        Video.list (err, data) =>
          @videos = data.videos

    play: (video)->
      console.log "requesting #{video.path}"
      @Video.play video
