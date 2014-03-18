config = require 'config'
logger = require('log4js').getLogger('streamer')
fs = require 'fs'

ffmpeg = require 'fluent-ffmpeg'

BinaryServer = require('binaryjs').BinaryServer

bs = new BinaryServer {port: config['streamer']['port']}

getPath = (path)-> __dirname + '/../video/' + path

createStream = (stream, fileName, {start, end}, cb) ->
  path = getPath fileName
  command = new ffmpeg { source: path, timeout: 0, logger }
  #outputStream = fs.createWriteStream()

  start = start or 0
  end = end or start + 60
  duration = end - start

  logger.debug 'path', path
  logger.debug 'start', start
  logger.debug 'end', end
  logger.debug 'duration', duration
  logger.debug 'stream', stream

  command
  #.addOption('-threads', config['ffmpeg']['maxthreads'] || 4)
  .setStartTime(0)
  .setDuration(60)
  .on("start", (commandLine) ->
    console.log "Spawned FFmpeg with command: " + commandLine
    return
  ).on("codecData", (data) ->
    console.log "Input is " + data.audio + " audio with " + data.video + " video"
    return
  ).on("progress", (progress) ->
    console.log "Processing: " + progress.percent + "% done"
    return
  ).on("error", (err) ->
    console.log "Cannot process video: " + err.message
    logger.debug err
    cb err
    return
  ).on("end", ->
    cb null
    # The 'end' event is emitted when FFmpeg finishes
    # processing.
    console.log "Processing finished successfully"
    return
  )
  .writeToStream stream
  #.saveToFile '/tmp/video-1.webm'

  return stream

bs.on 'connection', (client)->
  client.on 'stream', (stream, meta)->
    switch meta.event
      when 'list'
        stream.write {
          videos: [
            {
              path: 'trailer.webm'
              name: 'trailer'
            }
            {
              path: 'nyan.webm'
              name: 'nyan'
            }
            {
              path: 'mv.webm'
              name: 'Music Video'
            }
#            {
#              path: 'tao-quan.mp4'
#              name: 'Tao Quan'
#            }
          ]
        }

      when 'request'
        #stat = fs.statSync getPath meta.path
        #stream.write {size: stat.size }
        #stream = fs.createReadStream __dirname + '/../video/' + meta.path , start: meta.start, end: meta.end
        createStream stream, meta.path, meta, ()->
          stream = fs.createReadStream '/tmp/video-1.webm'
          client.send stream
        #videoStream = createStream stream, meta.path, meta
        #client.send videoStream, meta