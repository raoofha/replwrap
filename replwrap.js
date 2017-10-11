#! /usr/bin/env node

var opts = require('minimist')(process.argv.slice(2), {
  default: {
    port: 60999,
    host: "localhost",
  }
});
var cmdname = opts._[0]
var help = "usage: replwrap program [--port 60999 --host localhost --print --raw] -- [args...]";
if (opts.help || opts.h){
  console.log(help);
}else if (cmdname) {
  var spawn = require('child_process').spawn;
  var cmd = spawn(cmdname, opts._.slice(1),  {stdio: ["pipe", 1, 2]})
  if(opts.raw){process.stdin.setRawMode(true);}
  process.stdin.pipe(cmd.stdin);

  cmd.on('exit', process.exit)
  process.on("SIGINT", function(){})

  var WebSocket = require('ws');
  var wss = new WebSocket.Server({
    host: opts.host,
    port: opts.port
  });
  wss.on('connection', function connection(ws) {
    ws.on('message', function incoming(message) {
      if(opts.print){console.log(message);}
      process.stdin.emit('data', message+"\n"); 
      //ws.send(message);
    });

    ws.send("hi I'm server");
  });
}else{
  console.log(help);
}
