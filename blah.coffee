srcds = require './main'

#checkServer = (ip, port, cb) ->

client = srcds '27.50.71.29', 25017, timeout: 1000

client.info (err, result) ->
  if err
    console.log "error", err
  else
    console.log "result", result

  client.close()
