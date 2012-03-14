# liverail-api 

## Purpose

This is a node interface to the protocol for querying Source based servers. More information on the protocol can be found here:

https://developer.valvesoftware.com/wiki/Server_Queries

It currently only supports the A2S\_INFO method, which is really the guts of it. If you have a need for A2S\_PLAYER feel free to add it in and shoot us a pull request. If that's beyond you, feel free to let us know and we may add it.

Created by [Pinion.](http://pinion.gg/)

## Installation

npm install srcds-info

## Demo

```javascript
var srcds = require('srcds-info');

srcds.init();

srcds.client.on('decoded', function(info) {
	console.log(info);
	srcds.client.close();
});

srcds.info('203.217.24.85', 27017, function(err) {
	if (err) console.error(err)
});
```

## API

### srcds.init([port]); 
This takes no callback because dgram doesn't give you anything useful to bind it to. Port is optional. If not defined it will bind to a random port number.

### srcds.info(ip, port, [callback];
Queries the given credentials for information and emits the 'decoded' event once there is some useful information. Callback is optional, will only give you an error if something has gone wrong with the low level networking or similar.

### srcds.client.on('decoded', function(info) {do interesting things};
Passes back an object with the following properties: 
{ ip: string,
  port: number,
  serverName: string,
  map: string,
  gameType: string,
  gameName: string,
  appID: number,
  numPlayers: number,
  maxPlayers: number,
  numBots: number,
  dedicated: string(dedicated, listen, SourceTV),
  os: string(Linux, Windows),
  pw: boolean,
  secure: boolean }

Sometimes servers will send back a blank info response. This seems to be a protection against an old DOS attack. If a stripped packet is received, an 'error' event will be emitted with an object containing ip and port properties.

You may also listen for all of the events emitted by a standard [dgram](http://nodejs.org/docs/latest/api/dgram.html)
