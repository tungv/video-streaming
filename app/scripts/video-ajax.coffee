videos = [
  {
    name: "Music Video", path: 'mv.webm'
  }
]

id = Math.random()

createSrc = (array)->
  (window.URL || window.webkitURL).createObjectURL(new Blob(array))

intVal = null
round = (n, digit=3) ->
  co = 1
  co = switch digit
    when 1 then 10
    when 2 then 100
    when 3 then 1000
    else  co *= 10 for i in [1..digit]

  ~~(n * co) / co

getMeta = (eVideo) ->
  buffered = eVideo.buffered
  meta =
    duration: eVideo.duration
    currentTime:eVideo.currentTime
    buffered: ({start: buffered.start(i), end: buffered.end(i)} for i in [0..buffered.length-1]) if buffered.length
    state: eVideo.readyState

  return meta

calcPx = (position, duration)-> position / duration * 500

render = ($process, meta)->
  return unless meta.buffered

  duration = meta.duration
  ranges = $process.find('.buffered-ranges')
  currentTime = $process.find('.current-time')

  currentTime.css {width: calcPx meta.currentTime, duration}

  meta.buffered.forEach ({start,end})->
#    console.log start,end
    div = $('<div/>').css({
      position: 'absolute'
      left: "#{calcPx start, duration}px"
      width: "#{calcPx end - start + 1, duration}px"
      height: '2px'
      background: 'gray'
    })

    div.appendTo ranges

  ###$('#current-time').text round meta.currentTime
  $('#buffered-0').text "#{round meta.buffered[0].start}-#{round meta.buffered[0].end}" if meta.buffered
  $('#state').text meta.state
  console.log "hit: #{meta.currentTime }" if round meta.currentTime is round meta.buffered?[0].end
###

$ ()->
  $video = $('video')
  eVideo = $video[0]
  $process = $('.process[data-for=video-1]')

  $process.on 'click', '.capture', (e) ->
    x = e.pageX
    y = e.pageY
    $process.find('.tooltip').css {position: 'fixed', left: x}

  #eVideo.src = eVideo.currentSrc + '?id=' + id

  eVideo.addEventListener 'progress', ()->
    meta = getMeta eVideo
    #console.log meta.currentTime, meta.buffered?[0].end

  events = ["abort", "canplay", "canplaythrough", "durationchange", "emptied", "ended", "error", "loadeddata", "loadedmetadata", "loadstart", "pause", "play", "playing", "progress", "ratechange", "seeked", "seeking", "stalled", "suspend", "timeupdate", "volumechange", "waiting"]
  ###events.forEach (event)->
    return if event is 'timeupdate'
    eVideo.addEventListener event, ()->
      console.log "Event: #{event}"
    , false###

  ###$('#play').on 'click', ()->
    start = 0
    video = videos[0]
    promise = $.ajax {
      url: "/video/#{video.path}?start=#{start}"
      #type: 'ArrayBuffer'
    }

    promise.success (data)->
      $video.attr 'src', createSrc(data)

    promise.fail (err)->
      console.error err###

  $video.on 'timeupdate', ()->
    meta = getMeta eVideo
    render $process, meta

