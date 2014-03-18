ffmpeg = require 'fluent-ffmpeg'

command = new ffmpeg { source: __dirname + '/../video/mv.mp4', timeout: 0 }
  .toFormat('webm')
  .addOption('-threads', '64')
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
    return
  ).on "end", ->

    # The 'end' event is emitted when FFmpeg finishes
    # processing.
    console.log "Processing finished successfully"
    return
  .saveToFile(__dirname + '/../video/mv.webm')