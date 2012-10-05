dgram = require "dgram"
packet = require "packet"
EventEmitter = require('events').EventEmitter

PACKETS = 
  info: new Buffer [
    "0xff", "0xff", "0xff", "0xff", "0x54", "0x53", "0x6f", "0x75",
    "0x72", "0x63", "0x65", "0x20", "0x45", "0x6e", "0x67", "0x69",
    "0x6e", "0x65", "0x20", "0x51", "0x75", "0x65", "0x72", "0x79", "0x00"
  ]

RESPONSES =
  info: """
    x32,
    b8|chr() => type,
    b8 => version,
    b8z|utf8() => serverName,
    b8z|utf8() => map,
    b8z|utf8() => gameType,
    b8z|utf8() => gameName,
    l16 => appID,
    b8 => numPlayers,
    b8 => maxPlayers,
    b8 => numBots,
    b8|chr() => dedicated,
    b8|chr() => os,
    b8 => password,
    b8 => secure,
    b8z|utf8() => gameVersion
  """

class SrcDS extends EventEmitter
  constructor: (ip, port, options={}) ->
    return new SrcDS(ip, port, options) if this is global
    [@ip, @port, @options] = [ip, port, options]

    @client = dgram.createSocket 'udp4'
    parser = new packet.Parser()
    parser._transforms.chr = (parsing, field, value) -> if parsing then String.fromCharCode(value) else value.charCodeAt()
    parser.extract RESPONSES.info, (msg) =>
      @onMsg msg
    @client.on 'message', (msg, rinfo) =>
      @ip = rinfo.address
      @port = rinfo.port
      parser.write msg

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
    decoded = msg
    decoded.ip = @ip
    decoded.port = @port

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
