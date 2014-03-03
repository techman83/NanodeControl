ko.bindingProvider.instance = new StringInterpolatingBindingProvider();
var socket = new WebSocket(ws_path)

function onlyUnique(value, index, self) {
      return self.indexOf(value) === index;
}

var viewModel = {
  stations: ko.mapping.fromJS([]),
  schedules: ko.mapping.fromJS([]),
  pipins: [1,2,3,4],
  controlTypes: [{"name":"On/Off", "type":"onoff"}],
  dows: [
    {"name":"Sunday", "value":"0"},
    {"name":"Monday", "value":"1"},
    {"name":"Tuesday", "value":"2"},
    {"name":"Wednesday", "value":"3"},
    {"name":"Thursday", "value":"4"},
    {"name":"Friday", "value":"5"},
    {"name":"Saturday", "value":"6"},
  ],
  modeTab: ko.observable('stations')
}

viewModel.categoryDuplicates = ko.computed(function() {
  return viewModel.stations().map(function(item) {
    return (item.category ? item.category() : '')
  })
}) 

viewModel.categories = ko.computed(function() {
  return viewModel.categoryDuplicates().filter(onlyUnique)
})

ko.bindingHandlers.dump = {
  init: function (element, valueAccessor, allBindingsAccessor, viewmodel, bindingContext) {
    var context = valueAccessor();
    var allBindings = allBindingsAccessor();
    var pre = document.createElement('pre');

    element.appendChild(pre);

    var dumpJSON = ko.computed({
      read: function () {
        return ko.toJSON(context, null, 2);
      },
      disposeWhenNodeIsRemoved: element
    });

    ko.applyBindingsToNode(pre,
      {text: dumpJSON}
    );
  }
};


ko.applyBindings(viewModel);

socket.onopen = function() {
  document.getElementById('conn-status').innerHTML = 'Connected';
};

var messagehandler = function (msg) {
  data = JSON.parse(msg.data)
  console.log(data);
  if (data.msg) {
    data = JSON.parse(data.msg)
    console.log(data)
    if (data.type == 'remove') {
      viewModel[data.collection].remove(function(item) {
        return item._id.$oid() == data.content._id.$oid;
      })
    }
    if (data.type == 'insert') {
      viewModel[data.collection].push(ko.mapping.fromJS(data.content))
    }
    if (data.type == 'update') {
      var match = ko.utils.arrayFirst(viewModel[data.collection](), function(item) {
        return data.content._id.$oid === item._id.$oid();
      });
      if (match) {
        viewModel[data.collection].splice(viewModel.stations.indexOf(match),1,ko.mapping.fromJS(data.content));
      }
    }
    if (data.type == 'notify') {
      console.log("Notification here");
    }
  }
}

var ready = false;
var listenSockets = function() {
  if (ready) {
    socket.onmessage = messagehandler
  }
  ready = !ready
}



$.get( "/api/stations")
  .done(function(data) {
    ko.mapping.fromJSON(data, viewModel.stations)
    listenSockets()
  })

$.get( "/api/schedules")
  .done(function(data) {
    ko.mapping.fromJSON(data, viewModel.schedules)
    listenSockets()
  })


$(function () {
  $('#starttime').datetimepicker({
    pickDate: false,            // disables the date picker
    useSeconds: true,
  });
});
$(function () {
  $('#duration').datetimepicker({
    pickDate: false,            // disables the date picker
    useSeconds: true,
  });
});

var masterStationsSelectDisplay = function(apikey) {
  return viewModel.stations().filter(function(station) {
    return (station.apikey() == apikey)
  })[0].name();
}

var dowDisplay = function(value) {
  return viewModel.dows.filter(function(day) {
    return (day.value == value)
  })[0].name;
}
