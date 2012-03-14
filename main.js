var dgram = require('dgram');
var infoPacket = new Buffer(['0xff', '0xff', '0xff', '0xff', '0x54', '0x53', '0x6f', '0x75', '0x72', '0x63', '0x65', '0x20', '0x45', '0x6e', '0x67', '0x69', '0x6e', '0x65', '0x20', '0x51', '0x75', '0x65', '0x72', '0x79', '0x00']);

var srcds = exports;

srcds.init = function(port) {
	srcds.client = dgram.createSocket("udp4", onMsg);
	srcds.client.bind(port);
}

srcds.info = function(ip, port, cb) {
	srcds.client.send(infoPacket, 0, infoPacket.length, port, ip, function(err) {
		if ( typeof cb !== 'undefined') {
			if (err) {
				cb(err);
			} else {
				cb(false);
			}
		}
	});
};

var onMsg = function(msg, rinfo) {
	var decoded = {
		ip: rinfo.address,
		port: rinfo.port
	};
	var points = [6];
	for ( var i = 0 ; i < msg.length ; i++ ) {
		if (msg.readUInt8(i) === 0) {
			points.push(i);
		};
	};

	if ( points.length < 2 ) {
		srcds.client.emit('error' decoded);
		return;
	};

	// Here be dragons.
	// This protocol is outlined here: https://developer.valvesoftware.com/wiki/Server_Queries#Source_servers
	// Fields are delimited by 0x00 bytes, however things like whether a password is required may also be 0x00
	// Case 4 is such a nightmare because after the gameName field we can no longer be certain we won't hit an 0x00 that isn't delimiting a field, but is actually useful information.
	// For this reason, we don't decode out the game version. If you really need it, it can probably be done by working backwards from the end of the buffer, but I don't want to. Feel free to send a pull request!
	for ( var i = 0 ; i < points.length ; i++ ) {
		switch (i) {
			case 0:
				decoded.serverName = decString(msg, points[i], points[i + 1])
				break;
			case 1:
				decoded.map = decString(msg, (points[i]+1), points[i + 1])
				break;
			case 2:
				decoded.gameType = decString(msg, (points[i]+1), points[i + 1])
				break;
			case 3:
				decoded.gameName = decString(msg, (points[i]+1), points[i + 1])
				break;
			case 4:
				decoded.appID = decSigned(msg, (points[i] + 1))
				decoded.numPlayers = decInt(msg, (points[i]+ 3))
				decoded.maxPlayers = decInt(msg, (points[i]+ 4))
				decoded.numBots = decInt(msg, (points[i]+ 5))
				decoded.dedicated = decString(msg, (points[i]+ 6), (points[i] + 7))
				decoded.os = decString(msg, (points[i]+ 7), (points[i]+ 8))
				decoded.pw = decInt(msg, (points[i]+ 8))
				decoded.secure = decInt(msg, (points[i]+ 9))
				break;
		}
	}
	// Pretty things up a little
	switch(decoded.os) {
		case 'l':
			decoded.os = 'Linux';
			break;
		case 'w':
			decoded.os = 'Windows';
			break;
	}
	switch(decoded.dedicated) {
		case 'd':
			decoded.dedicated = 'dedicated';
			break;
		case 'l':
			decoded.dedicated = 'listen';
			break;
		case 'p':
			decoded.dedicated = 'SourceTV';
			break;
	}
	decoded.pw = (decoded.pw === 1);
	decoded.secure = (decoded.secure === 1);
	srcds.client.emit('decoded', decoded);
};

var decString = function(buf, start, end) {
	return buf.toString('utf8', start, end)
}

var decHex = function(buf, pos) {
	return buf.toString('hex', pos, pos + 1)
}

var decInt = function(buf, pos) {
	return buf.readUInt8(pos)
}

var decSigned = function(buf, pos) {
	return buf.readInt16LE(pos)
}

var info = function(ip, port) {
	var infopacket = new buffer(['0xff', '0xff', '0xff', '0xff', '0x54', '0x53', '0x6f', '0x75', '0x72', '0x63', '0x65', '0x20', '0x45', '0x6e', '0x67', '0x69', '0x6e', '0x65', '0x20', '0x51', '0x75', '0x65', '0x72', '0x79', '0x00']);
	client.send(infopacket, 0, infopacket.length, port, ip, function(err, bytes) {
		if (err) {
			srcds.client.emit('error', err);
			console.error(err);
		}
	});
}
