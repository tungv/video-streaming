logger = require('log4js').getLogger('app')
config = require 'config'

fs = require 'fs'

express = require 'express'
app = express()

exports.start = ->
  port = config['app']['port']
  app.listen port
  logger.info "App started on port #{port} - mode: #{app.get 'env'}"

  require './streamer.coffee'

app.use express.static __dirname + '/../app'
app.use express.json()




###

app.use '/video', express.static __dirname + '/../video'
app.get '/video1/:file.:ext', (req, res)->
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

