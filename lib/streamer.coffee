config = require 'config'
logger = require('log4js').getLogger('streamer')
fs = require 'fs'

BinaryServer = require('binaryjs').BinaryServer

bs = new BinaryServer {port: config['streamer']['port']}

getPath = (path)-> __dirname + '/../video/' + path

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
              path: 'mv.mp4'
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
        stream = fs.createReadStream __dirname + '/../video/' + meta.path , start: meta.start, end: meta.end
        client.send stream