var app = require('http').createServer(handler),
  io = require('socket.io').listen(app),
  fs = require('fs'),
  spawn = require('child_process').spawn;

var PORT = 41100;

app.listen(PORT);
console.log("web server started on port " + PORT);

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

// websockets
io.sockets.on('connection', function (socket) {
  socket.on('control', function (data) {
    console.log(" receiving data ");
    var type = 'play';
    if(data.type) type = data.type;
    spawn('./control', [type],  {cwd: process.cwd()});
  });
});
