logger = require('log4js').getLogger('app')
config = require 'config'

fs = require 'fs'

ffmpeg = require 'fluent-ffmpeg'

express = require 'express'
app = express()

exports.start = ->
  port = config['app']['port']
  app.listen port
  logger.info "App started on port #{port} - mode: #{app.get 'env'}"

  #require './streamer.coffee'

app.use express.static __dirname + '/../app'
app.use express.json()

#app.get '/video/:filename', (req, res)->
#  {filename} = req.params
#  path = "#{__dirname}/../video/#{filename}"
#  res.contentType 'video/webm'
#  command = createCmd path, req.query
#  ##command.writeToStream res,  {end:true}
#
#  command.saveToFile "#{__dirname}/../video/#{filename}_#{ req.query.start}"





app.use '/video', express.static __dirname + '/../video'
###app.get '/video1/:file.:ext', (req, res)->
  {file, ext} = req.params
  path = req.path
  path = __dirname+'/..' + path

  logger.debug "path=#{path}"
  logger.debug "fileName=#{file} - extension: #{ext}"

  stats = fs.statSync path
  total = stats.size

  range = req.headers.range
  positions = range.replace /bytes=/, ""
  positions = positions.split '-'

  logger.debug 'positions', positions

  start = Number positions[0]
  end = if positions[1] then positions[1] else total-1

  logger.debug 'end', end
  end = Number end

  chunksize = (end-start)+1;

  logger.debug "total=#{total}\tstart=#{start} - end=#{end} / chunksize=#{chunksize}"

  res.writeHead 206, {
    "Content-Range": "bytes " + start + "-" + end + "/" + total
    "Accept-Ranges": "bytes"
    "Content-Length": chunksize
    "Content-Type":"video/mp4"
  }

  stream = fs.createReadStream(path, { flags: "r", start: start, end: end });
  stream.pipe res

  res.on 'close', ->
    console.log 'closing stream'
    stream.destroy()

  logger.debug '\n\n'
###


createCmd = (fileName, {start, end}) ->
  path = fileName
  command = new ffmpeg { source: path, timeout: 0, logger }
  #outputStream = fs.createWriteStream()

  start = start or 0
  end = end or start + 60
  duration = end - start

  logger.debug 'path', path
  logger.debug 'start', start
  logger.debug 'end', end
  logger.debug 'duration', duration

  return command
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
    #cb err
    return
  ).on("end", ->
    #cb null

    # The 'end' event is emitted when FFmpeg finishes
    # processing.
    console.log "Processing finished successfully"
    return
  )