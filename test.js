var srcds = require('./main.js')
, assert = require('assert')
;

// If the tests aren't passing, it might just be that the server it's trying to query is down. You can cross check that here: 
// http://www.gametracker.com/server_info/27.50.71.3:21015/
// If it is down, find a Team Fortress 2 server that isn't and change the IP and port accordingly
client = srcds('27.50.71.3', 21045);

client.info(function(err,info){
  if (err) throw new Error(err)
  assert.deepEqual((typeof info.serverName), 'string');
  assert.deepEqual((typeof info.map), 'string');
  assert.deepEqual((typeof info.gameType), 'string');
  assert.deepEqual((typeof info.dedicated), 'string');
  assert.deepEqual((typeof info.os), 'string');
  assert.deepEqual((typeof info.ip), 'string');
  assert.deepEqual((typeof info.pw), 'boolean');
  assert.deepEqual((typeof info.secure), 'boolean');
  assert.deepEqual((typeof info.numPlayers), 'number');
  assert.deepEqual((typeof info.maxPlayers), 'number');
  assert.deepEqual((typeof info.numBots), 'number');
  assert.deepEqual((typeof info.port), 'number');
  assert.deepEqual(info.gameType, 'tf');
  assert.deepEqual(info.gameName, 'Team Fortress');
  assert.deepEqual(info.appID, 440);
  client.close();
  console.log('All tests passed');
});

