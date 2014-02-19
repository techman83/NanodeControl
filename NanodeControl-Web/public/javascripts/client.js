var socket = new WebSocket(ws_path)

socket.onmessage = function(e) {
  var data = JSON.parse(e.data);
  console.log(data);
};
