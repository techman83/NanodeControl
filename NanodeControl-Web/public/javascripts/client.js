var socket = new WebSocket(ws_path)

socket.onopen = function() {
  document.getElementById('conn-status').innerHTML = 'Connected';
};

socket.onmessage = function(e) {
  var data = JSON.parse(e.data);
  console.log(data);
};

function get_data() {
  $.ajax({
    url: "/api/stations",
    type: 'Get'
  });
  console.log("Get station data");
}
