ko.bindingProvider.instance = new StringInterpolatingBindingProvider();
var socket = new WebSocket(ws_path)

function onlyUnique(value, index, self) {
      return self.indexOf(value) === index;
}

var viewModel = {
  stations: ko.mapping.fromJS([]),
  pipins: ko.mapping.fromJS([1,2,3,4]),
  controlTypes: ko.mapping.fromJS([{"name":"On/Off", "type":"onoff"}]),
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

$.get( "/api/stations", function( data ) {
})
  .done(function(data) {
    ko.mapping.fromJSON(data, viewModel.stations)
    socket.onmessage = function (msg) {
      data = JSON.parse(msg.data)
      console.log(data);
      if (data.msg) {
        data = JSON.parse(data.msg)
        console.log(data)
        if (data.type == 'remove') {
          viewModel.stations.remove(function(item) {
            return item._id.$oid() == data.content._id.$oid;
          })
        }
        if (data.type == 'insert') {
          viewModel.stations.push(ko.mapping.fromJS(data.content))
        }
        if (data.type == 'update') {
          var match = ko.utils.arrayFirst(viewModel.stations(), function(item) {
            return data.content._id.$oid === item._id.$oid();
          });
          if (match) {
            viewModel.stations.splice(viewModel.stations.indexOf(match),1,ko.mapping.fromJS(data.content));
          }
        }
        if (data.type == 'notify') {
          console.log("Notification here");
        }
      }
    }
  })

$(function () {
    $('#starttime').datetimepicker({
        pickDate: false
    });
});
$(function () {
    $('#duration').datetimepicker({
        pickDate: false
    });
});
