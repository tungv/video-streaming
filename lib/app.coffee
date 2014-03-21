logger = require('log4js').getLogger('app')
config = require 'config'

fs = require 'fs'

ffmpeg = require 'fluent-ffmpeg'
express = require 'express'
app = express()

exports.start = ->
  port = config['app']['port']
  http = app.listen port
  logger.info "App started on port #{port} - mode: #{app.get 'env'}"

  #monitor.Monitor http

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

round = (n, digit=3) ->
  co = 1
  co = switch digit
    when 1 then 10
    when 2 then 100
    when 3 then 1000
    else  co *= 10 for i in [1..digit]

  ~~(n * co) / co

size = (bytes)->
  if bytes < 1024 then return round(bytes) + 'B'

  bytes /= 1024
  if bytes < 1024 then return round(bytes) + 'KB'
  bytes /= 1024
  if bytes < 1024 then return round(bytes) + 'MB'

counter = []

#app.use '/video', express.static __dirname + '/../video'
#return

app.get '/video/:file.:ext', (req, res, next)->
  {file, ext} = req.params
  path = req.path
  path = __dirname+'/..' + path
  id = req.query.id

  match = counter.filter (item)-> item.id
  if match.length is 0
    item = {id, size: 0}
    counter.push item
    #logger.debug 'counter', counter
  else
    item = match[0]

  #logger.debug "path=#{path}"
  #logger.debug "fileName=#{file} - extension: #{ext}"

  stats = fs.statSync path
  total = stats.size

  range = req.headers.range
  return next() if !range
  positions = range.replace /bytes=/, ""
  positions = positions.split '-'

  #logger.debug 'positions', positions

  start = Number positions[0]
  end = if positions[1] then positions[1] else total-1

  #logger.debug 'end', end
  end = Number end

  chunksize = (end-start)+1;
  maxChunkSize = if start is 0 then 256*1024 else 2 * 1024 * 1024
  if chunksize > maxChunkSize then chunksize = maxChunkSize
  end = start + chunksize - 1

  item.size += chunksize
  logger.debug "#{start}-#{end}/#{total} SIZE=#{ size chunksize} (transfered=#{item.size})"

  res.writeHead 206, {
    "Content-Range": "bytes " + start + "-" + end + "/" + total
    "Accept-Ranges": "bytes"
    "Content-Length": chunksize
    "Content-Type":"video/mp4"
    'ETag': [stats.size, stats.mtime, start, end].join '-'
    #'Cache-Control':'max-age=600'
  }


  stream = fs.createReadStream(path, { flags: "r", start: start, end: end });
  stream.pipe res

  res.on 'close', ->
    console.log 'closing stream'
    stream.destroy()


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