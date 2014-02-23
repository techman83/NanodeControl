ko.bindingProvider.instance = new StringInterpolatingBindingProvider();
var socket = new WebSocket(ws_path)

function onlyUnique(value, index, self) {
      return self.indexOf(value) === index;
}

var viewModel = {
  stations: ko.mapping.fromJS([]),
}

viewModel.categoryDuplicates = ko.computed(function() {
  return viewModel.stations().map(function(item) {
    return (item.category ? item.category() : '')
  })
}) 
                                                                                                      
viewModel.categories = ko.computed(function() {
  return viewModel.categoryDuplicates().filter(onlyUnique)
})

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
            return item._id.$oid() == data.content
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
        }
      }
    }
  })

function addStation(data) {

}
