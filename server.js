var app = require('http').createServer(handler),
  io = require('socket.io').listen(app),
  fs = require('fs'),
  spawn = require('child_process').spawn;

var PORT = 41100;

app.listen(PORT);
printHelp(); // print help message for the user

// http server
function handler (req, res) {
  fs.readFile(__dirname + '/index.html',
  function (err, data) {
    if (err) {
      res.writeHead(500);
      return res.end('Error loading index.html');
    }
    res.writeHead(200);
    res.end(data);
  });
}

// reduced logging
io.set('log level', 1);

// websockets
io.sockets.on('connection', function (socket) {
  socket.on('control', function (data) {
    console.log(" receiving data ");
    var type = 'play';
    if(data.type) type = data.type;
    spawn('./control', [type],  {cwd: process.cwd()});
  });
});

function printHelp() {
  //get local Interfaces
  var interfaces = require('os').networkInterfaces();
  var interfaceList = [];

  for(var interface in interfaces){
    // pointless to show the loopback address
    if(interface.indexOf('lo') === 0)
      continue;

    // loop through all ipv4 ip addresses
    // XXX why not ipv6 ? i dont use it.
    // can add it if someone does require it
    for(var address in interfaces[interface]){
      if(interfaces[interface][address].family == 'IPv4') {
        // add if not already in the array
        if(interfaceList.indexOf(interfaces[interface][address].address) === -1)
          interfaceList.push(interfaces[interface][address].address);
      }
    }
  }

  //print appropriate help message
  if(interfaceList.length === 1)
    console.log("access the server at : " + interfaceList[0] + ":" + PORT);
  else if(interfaceList.length > 1) {
    console.log("access ther server at one of the appropriate endpoints");
    for(var index in interfaceList) {
      var ip = interfaceList[index];
      console.log(" -> " + ip + ":" + PORT);
    }
  }
  else {
    console.log("web server started on port " + PORT);
  }
}
