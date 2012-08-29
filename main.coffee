dgram = require "dgram"
EventEmitter = require('events').EventEmitter

PACKETS = 
  info: new Buffer [
    "0xff", "0xff", "0xff", "0xff", "0x54", "0x53", "0x6f", "0x75",
    "0x72", "0x63", "0x65", "0x20", "0x45", "0x6e", "0x67", "0x69",
    "0x6e", "0x65", "0x20", "0x51", "0x75", "0x65", "0x72", "0x79", "0x00"
  ]


decString = (buf, start, end) ->
  if end < start
    ""
  else if end > buf.length
    ""
  else
    buf.toString "utf8", start, end

decHex = (buf, pos) ->
  buf.toString "hex", pos, pos + 1

decInt = (buf, pos) ->
  if pos > buf.length
    0
  else
    buf.readUInt8 pos

decSigned = (buf, pos) ->
  buf.readInt16LE pos



class SrcDS extends EventEmitter
  constructor: (ip, port, options={}) ->
    return new SrcDS(ip, port, options) if this is global
    [@ip, @port, @options] = [ip, port, options]

    @client = dgram.createSocket 'udp4'
    @client.on 'message', @onMsg

    @options.timeout ||= 10000


  send: (packet, cb=->) ->
    @client.send packet, 0, packet.length, @port, @ip, (err) =>
      if err 
        cb err
      else
        #This is a bit crap - should figue out a way of matching responses to requests or queueing
        timeout = null
        msgcb = (msg) ->
          clearTimeout timeout
          cb null, msg
        
        @once 'message', msgcb
        
        timeout = setTimeout =>
          @removeListener 'message', msgcb
          cb new Error "Request timed out"
        , @options.timeout

  info: (cb) -> @send PACKETS.info, cb

  onMsg: (msg, rinfo) =>
    decoded =
      ip: rinfo.address
      port: rinfo.port

    points = [6]
    i = 0

    while i < msg.length
      points.push i  if msg.readUInt8(i) is 0
      i++
    if points.length < 3
      @emit "error", decoded
      return
    
    # Here be dragons.
    # This protocol is outlined here: https://developer.valvesoftware.com/wiki/Server_Queries#Source_servers
    # Fields are delimited by 0x00 bytes, however things like whether a password is required may also be 0x00
    # Case 4 is such a nightmare because after the gameName field we can no longer be certain we won't hit an 0x00 that isn't delimiting a field, but is actually useful information.
    # For this reason, we don't decode out the game version. If you really need it, it can probably be done by working backwards from the end of the buffer, but I don't want to. Feel free to send a pull request!
    i = 0

    while i < points.length
      switch i
        when 0
          decoded.serverName = decString(msg, points[i], points[i + 1])
        when 1
          decoded.map = decString(msg, (points[i] + 1), points[i + 1])
        when 2
          decoded.gameType = decString(msg, (points[i] + 1), points[i + 1])
        when 3
          decoded.gameName = decString(msg, (points[i] + 1), points[i + 1])
        when 4
          decoded.appID = decSigned(msg, (points[i] + 1))
          decoded.numPlayers = decInt(msg, (points[i] + 3))
          decoded.maxPlayers = decInt(msg, (points[i] + 4))
          decoded.numBots = decInt(msg, (points[i] + 5))
          decoded.dedicated = decString(msg, (points[i] + 6), (points[i] + 7))
          decoded.os = decString(msg, (points[i] + 7), (points[i] + 8))
          decoded.pw = decInt(msg, (points[i] + 8))
          decoded.secure = decInt(msg, (points[i] + 9))
      i++
    
    # Pretty things up a little
    switch decoded.os
      when "l"
        decoded.os = "Linux"
      when "w"
        decoded.os = "Windows"
    switch decoded.dedicated
      when "d"
        decoded.dedicated = "dedicated"
      when "l"
        decoded.dedicated = "listen"
      when "p"
        decoded.dedicated = "SourceTV"
    decoded.pw = (decoded.pw is 1)
    decoded.secure = (decoded.secure is 1)
    @emit "message", decoded

  close: ->
    @client.close()

module.exports = SrcDS