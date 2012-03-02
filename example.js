var srcds = require('./main.js');

srcds.init();

srcds.client.on('decoded', function(info) {
	console.log(info);
	srcds.client.close();
});

// If the example isn't working, it might just be that the server it's trying to query is down. You can cross check that here: 
// http://www.gametracker.com/server_info/203.217.24.85:27017/
// If it is down, find one that isn't and change the IP and port accordingly
srcds.info('203.217.24.85', 27017, function(err) {
	if (err) console.error(err)
});
