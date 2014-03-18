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
    currentTime:eVideo.currentTime
    buffered: ({start: buffered.start(i), end: buffered.end(i)} for i in [0..buffered.length-1]) if buffered.length
    state: eVideo.readyState

  return meta

render = (meta)->
  $('#current-time').text round meta.currentTime
  $('#buffered-0').text "#{round meta.buffered[0].start}-#{round meta.buffered[0].end}" if meta.buffered
  $('#state').text meta.state
  console.log "hit: #{meta.currentTime }" if round meta.currentTime is round meta.buffered?[0].end


$ ()->
  $video = $('video')
  eVideo = $video[0]

  eVideo.src = eVideo.currentSrc + '?id=' + id

  eVideo.addEventListener 'progress', ()->
    meta = getMeta eVideo
    console.log meta.currentTime, meta.buffered?[0].end

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

  intVal = setInterval ()->
    meta = getMeta eVideo
    render meta
  , 10

