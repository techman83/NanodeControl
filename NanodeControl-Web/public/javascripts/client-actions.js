var addStation = function (data) {
  console.log("add station");

  $.ajax({
    url: "/api/stations",
    type: 'POST',
    data: ko.toJSON(data),
    dataType: 'json',
    success: function(id) {
      console.log(ko.toJSON(data));
    }
  })
}

var setStationOnoff = function () {
  var self = this;

  // self will send current state, we want to change it
  var state = true;
  if (! self.state) {
    state = true;
  } else if (self.state() ){
    state = '';
  }

  $.ajax({
    url: "/api/stations/partial/" + self.id(),
    type: 'POST',
    data: JSON.stringify({
      state: state,
    }),
    dataType: 'json',
    success: function(id) {
      console.log( "Set State: " + self.id() );
    }
  })
}

var removeStation = function () {
  var self = this;
 
  console.log(self._id.$oid());
  
  $.ajax({
    url: "/api/stations/delete/" + self._id.$oid(),
    type: 'POST',
    success: function() {
      console.log( "Deleted Station " + self._id.$oid());
    }
  })
}
