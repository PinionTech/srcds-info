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

client = srcds('27.50.71.3', 21045);

client.info('203.217.24.85', 27017, function(err, info) {
	if (err) {
        	console.error(err)
	}
	else {
		console.log(info);
	}
	client.close();
});
```

## API

### srcds(server, port[, options]); 
Returns a client object for querying. Options is optional. Currently the only option is "timeout" which lets you change how long to wait for a response before emitting an error. The default is 10 seconds.

### client.info(callback);
Queries the given server and calls the callback with either an information object or an error. The object has the following properties: 
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

Sometimes servers will send back a blank info response. This seems to be a protection against an old DOS attack. If a stripped packet is received, an 'error' will be returned with an object containing ip and port properties.

### client.close()

Cleans up the connection associated with a client.
