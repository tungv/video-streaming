console.info 'loaded'

win = window

win.App = angular.module 'VideoApp', []

angular.module 'VideoApp'
  .constant 'config', {
    streamer:
      port: 9000
  }

angular.module 'VideoApp'
  .service 'Video', ($timeout, config, $location)->
    hostname = window.location.hostname
    client = new BinaryClient "ws://#{hostname}:#{config.streamer.port}"

    emit = (event, data={}, file={})->
      data.event = event
      client.send(file, data)

    list = (cb)->
      stream = emit 'list'

      stream.on 'data', (data)->
        $timeout ()->
          cb null, data
        , 0

      stream.on 'error', (err)->
        $timeout ()->
          cb err
        , 0

    video = document.querySelector('video')
    sourceBuffer = null
    queue = []

    ## set up new source buffer
    ms = new (window.MediaSource or window.WebKitMediaSource)
    video.src = window.URL.createObjectURL ms

    ms.addEventListener 'webkitsourceopen', ()->
      console.log 'webkitsourceopen'

    ms.addEventListener 'sourceopen', ()->
      console.log 'sourceopen'

    video.addEventListener 'error', (e)->
      console.warn 'video error', e


    play = (video, cb)->
      start = 0
      end = 300e6 #(first 30MB)

      queue = [] ## clear queue

      fn = ()->
        console.log 'zo day di'
        sourceBuffer = ms.addSourceBuffer('video/webm;codecs="vp8, vorbis"')

        sourceBuffer.addEventListener 'update', ->
          if ( queue.length )
            sourceBuffer.appendBuffer(queue.shift())
          else
            #ms.endOfStream()

        emit 'request', {path: video.path, start, end}

      if ms.readyState isnt 'open'
        ms.addEventListener 'sourceopen', fn
      else
        setTimeout fn, 0




    download = (stream, cb) ->

      count = 0

      stream.on 'data', (data)->
        queue.push data
        sourceBuffer.appendBuffer(queue.shift()) if count++ is 0


      stream.on 'error', (err)->
        cb err

      stream.on 'end', ->
        #ms.endOfStream() unless queue.length
        cb null

    client.on 'stream', (stream)->
      download stream, (err, src)->
        #$('video').attr('src', src)

    return {
      list
      download
      play
      on: -> client.on arguments...
    }