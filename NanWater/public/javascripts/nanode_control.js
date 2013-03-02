var timeout = 15000;

$(document).on('pageshow',function(event, ui){
  if (event.target.id == 'control') {
    // set initial states
    $('select').each(function() {
      if($(this).hasClass('state-HIGH')) {
        console.log(this.id + ' HIGH');
        $('#' + this.id).val('HIGH').slider("refresh");
      } else {
        console.log(this.id + ' LOW');
        $('#' + this.id).val('LOW').slider("refresh");
      }
    }); // togglebox foreach
  }
});

// Pop message from returned JSON object
function messagepop(data) {
  if ( data.result != "success" ) {
    $("#popup_header").attr("data-theme","a").removeClass("ui-bar-b").addClass("ui-bar-a");
  }
  $("#error_heading").text(data.title);
  $("#error_content").text(data.message);
  $("#lnkInfo").click();
}

// Custom submit function
function submit (data) {
  $.mobile.showPageLoadingMsg(); 
  console.log($(this));
  data;
  $.ajax({
    type: "POST",
    url: data.url,
    data: JSON.stringify(data),
    dataType: "json",
    //async: false,
    timeout: timeout, // in milliseconds
    success: function(result) {
      // process data here
      var status = '';
      switch (result.result) {
        case 'success':
          $.mobile.hidePageLoadingMsg();
          console.log("Success:" + result.result);
          if (data.successpop) {
            messagepop(result);
          } else if  (data.noreload) {
            // prevent reload
          } else {
            location.reload();
          }
          status = '#';
          break;
        case 'failure':
          console.log("Failure:" + result.error);
          messagepop(result);
          break;
        default:
                $('div.fullscreen').show();
                $('div.' + data.result).show().empty().append(data.msg);
      }
      
      $.mobile.hidePageLoadingMsg();
    },
    error: function(request, status, err) {
      if (status == "timeout") {
              console.log('timeout'); 
              data.result = 'timeout';
              data.title = 'TIMEOUT';
              data.message = 'Request timed out, please refresh your browser.';
              console.log('data'); 
              messagepop(data);
              $.mobile.hidePageLoadingMsg();
      }
    }
  });
} // function submit

// Control stations
$(document).on('pageinit', function(e){
  if (e.target.id == 'control') {
    console.log("Control Stations"); 
    var controlstations = new Object();

    // On/Off controls
    $('select').change(function() {
      controlstations.id = this.id;
      controlstations.value = this.value;
      controlstations.url = "/stations/" + this.id;
      controlstations.noreload = 1;
      submit(controlstations);
    }); // On/Of controls

    // Slider controls
    $('input').change(function() {
      controlstations.id = $(this).attr("id");
      controlstations.val = $(this).val();
      var $this = $(this);
      var delay = 2000; // 2 seconds delay after last input
      controlstations.url = "/stations/" + this.id;
      controlstations.noreload = 1;

      clearTimeout($this.data('timer'));
      $this.data('timer', setTimeout(function(){
      $this.removeData('timer');
        console.log("Set id: " + controlstations.id);
        console.log("Set val: " + controlstations.val);
        submit(controlstations);
      }, delay));
    }); // Slider controls.
  } // e.target.id == 'control'
}); // Control stations

// Schedule
$(document).on('pageinit', function(e){
  if (e.target.id == 'schedule') {
    var schedule = new Object();
    console.log("Schedule");
    $("form[id='schedule']").submit(function(event) {
      event.stopPropagation();
      event.preventDefault();
      schedule.days = [];
      $(":checkbox:checked[id^='checkbox']").each(function() { 
           schedule.days.push($(this).val());
      });
      schedule.stations = [];
      $(":checkbox:checked[id^='station-']").each(function() { 
           schedule.stations.push($(this).attr("name"));
      });
      schedule.name = $('[name=name]').val();
      schedule.duration = $('[name=duration]').val();
      schedule.starttime = $('[name=starttime]').val();
      schedule.url = '/addschedule';
      schedule.successpop = 1;
      console.log("Submit: " + schedule);
      submit(schedule);
    });
     
    // Close station popup instead of submit.
    $("form[id^='station_select-']").submit(function(event) {
      event.stopPropagation();
      event.preventDefault();
      $("#" + this.id).popup("close")
    });
  }
}); // Schedule


// Categories
$(document).on('pageinit', function(e){
  if (e.target.id == 'categories') {
    var categories = new Object();
    console.log("Categories"); 
    $('form').submit(function(event) {
      console.log("Submit"); 
      event.stopPropagation();
      event.preventDefault();
      switch ($(this).attr('id')) {
        case 'removecategory':
          categories.categories = [];
          $(":checkbox:checked").each(function() { 
            console.log("Remove Category: " + $(this).attr("id"));
            categories.categories.push($(this).attr("id"));
          });
          categories.url = '/removecategory';
          submit(categories);
          break;
        case 'addcategory':
          console.log($('[name=name]').val());
          categories.url = '/addcategory';
          categories.categoryname = ($('[name=name]').val());
          submit(categories);
          break;
        default:
            // some sort error handling here
      }
      console.log($(this).attr('id'));
    }); // Categories submit
  }
}); // Categories

// Add station
$(document).on('pageinit', function(e){
  if (e.target.id == 'addstation') {
    var addstation = new Object();
    console.log("Add Station"); 
    $('form').submit(function(event) {
      event.stopPropagation();
      event.preventDefault();

      // addstation object
      addstation.stationname = $('[name=name]').val();
      addstation.stationurl = $('[name=stationurl]').val();
      addstation.stationcategory = $('[name=category]').val();
      addstation.stationtype = $('[name=type]').val();
      addstation.stationtype = $('[name=type]').val();
      addstation.stationreverse = $('[name=reverse]').val();
      addstation.successpop = 1;
      addstation.url = '/addstation';
      
      console.log("Add Station: " + addstation);
      submit(addstation);
    }); // submit
  } 
}); // Add station

// Remove stations
$(document).on('pageinit', function(e){
  if (e.target.id == 'removestation') {
    console.log("Remove Stations"); 
    var removestations = new Object();
    $('form').submit(function(event) {
      console.log("Submit"); 
      event.stopPropagation();
      event.preventDefault();
      removestations.stations = [];
      removestations.url = "/removestations";
      $(":checkbox:checked").each(function() { 
              console.log("Remove Station: " + $(this).attr("id"));
              removestations.stations.push($(this).attr("id"));
      });
      submit(removestations);
    }); // function submit
  }; // remove station submit 
}); // Remove stations

