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

var addSchedule = function (data) {
  console.log("add station");
  data = ko.toJS(data);  
  data.state = ''; // data model expects state to exist. Must fix that..
  data.duration = moment.duration(data.duration).asSeconds();

  $.ajax({
    url: "/api/schedules",
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
  var state = 'HIGH';
  if (! self.state) {
    state = 'HIGH';
  } else if (self.state() ){
    state = 'LOW';
  }

  console.log(self)

  $.ajax({
    url: "/api/" + self.apikey() + "/" + state,
    type: 'POST',
    success: function(id) {
      console.log( "Set State: " + self.id() );
      $("#" + self.id() + "-spinner").css("visibility","visible");
    }
  })
}

var scheduleState = function (state) {
  var self = this;
  console.log(self)

  $.ajax({
    url: "/api/" + self.apikey() + "/" + state,
    type: 'POST',
    success: function(id) {
      console.log( "Set Schedule State" );
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

var removeSchedule = function () {
  var self = this;
 
  console.log(self._id.$oid());
  
  $.ajax({
    url: "/api/schedules/delete/" + self._id.$oid(),
    type: 'POST',
    success: function() {
      console.log( "Deleted Station " + self._id.$oid());
    }
  })
}
