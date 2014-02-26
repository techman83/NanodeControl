var addStation = function (data) {
  console.log("add station");
}

var setStationOnoff = function () {
  var self = this;

  // self will send current state, we want to change it
  var state = 1;
  if (! self.state) {
    state = 1;
  } else if (self.state() ){
    state = 0;
  }

  $.ajax({
    url: "/api/stations/partial/" + self.id(),
    type: 'POST',
    data: JSON.stringify({
      key: 'state',
      value: state
    }),
    dataType: 'json',
    success: function(id) {
      console.log( "Set State: " + state, id );
    }
  })
}
