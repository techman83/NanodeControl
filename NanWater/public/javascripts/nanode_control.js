var timeout = 15000;

$(document).on('pageshow',function(event, ui){
  if (event.target.id == 'control') {
    // set initial states
    $('select').each(function() {
      if($(this).hasClass('state-255')) {
        console.log(this.id + ' 255');
        $('#' + this.id).val('255').slider("refresh");
      } else {
        console.log(this.id + ' 0');
        $('#' + this.id).val('0').slider("refresh");
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
    console.log("Remove Station"); 
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

$(document).on('pageinit', function(e){
                        function submit (name, url, category, type) {
                                $.mobile.showPageLoadingMsg(); 
                                console.log($(this)); 
                                var jsondata = { "stationname": name, "stationurl": url, "stationcategory": category, "stationtype": type };
                                $.ajax({
                                        type: "POST",
                                        url: "/addstation",
                                        contentType: 'application/json',
                                        dataType: "json",
                                        data: JSON.stringify(jsondata),
                                        //async: false,
                                        timeout: timeout, // in milliseconds
                                        success: function(data) {
                                                // process data here
                                                var status = '';
                                                switch (data.result) {
                                                        case 'success':
                                                                console.log("Success:" + data); 
                                                                $("#error_heading").text('Success') 
                                                                $("#error_content").text('Station Added Successfully.') 
                                                                $("#lnkInfo").click();
                                                                status = '#';
                                                                break;
                                                        case 'failure':
                                                                console.log("Failure:" + data.error);
                                                                if ( data.error == "undefined" ) {
                                                                  $("#error_heading").text('UNDEFINED') 
                                                                  $("#error_content").text('A field has been left blank. All fields are required.') 
                                                                  $("#lnkInfo").click();
                                                                }
                                                                $.mobile.hidePageLoadingMsg();
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
                                                        $("#popup_header").attr("data-theme","a").removeClass("ui-bar-b").addClass("ui-bar-a");
                                                        $("#error_heading").text('TIMEOUT');
                                                        $("#error_content").text('Request timed out, please refresh your browser.');
                                                        $("#lnkInfo").click();
                                                        console.log('click');
                                                        $.mobile.hidePageLoadingMsg();
                                                }
                                        }
                                });
                        } // function submit
        if (e.target.id == 'control') {
                // $(document).ready(function(){ <- This here does not work in jquery mobile. You will encounter hours of frustration until you learn this!
        
                // toggle actions
                        function submit (id, attr) {
                                $.mobile.showPageLoadingMsg(); 
                                $('#' + id).find('div.success,div.failure').stop(true,true).clearQueue();
                                $('#' + id).find('div.success,div.failure').hide();
                                console.log($(this)); 
                                var jsondata = { station: id, act: attr };
                                $.ajax({
                                        type: "POST",
                                        url: "/stations/:" + id,
                                        data: JSON.stringify(jsondata),
                                        dataType: "json",
                                        //async: false,
                                        timeout: timeout, // in milliseconds
                                        success: function(data) {
                                                // process data here
                                                var status = '';
                                                switch (data.result) {
                                                        case 'success':
                                                                console.log("Success:" + data.result); 
                                                                status = '#' + attr;
                                                                break;
                                                        case 'failure':
                                                                console.log("Failure:" + data.result); 
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
                                                        $("#popup_header").attr("data-theme","a").removeClass("ui-bar-b").addClass("ui-bar-a");
                                                        $("#error_heading").text('TIMEOUT');
                                                        $("#error_content").text('Request timed out, please refresh your browser.');
                                                        $("#lnkInfo").click();
                                                        console.log('click');
                                                        $.mobile.hidePageLoadingMsg();
                                                }
                                        }
                                });
                        } // function submit
                $('select').change(function() {
                        submit(this.id, this.value);
                }); // togglebox click
                $('input').change(function() {
                        var id = $(this).attr("id");
                        var val = $(this).val();
                        var $this = $(this);
                        var delay = 2000; // 2 seconds delay after last input

                        clearTimeout($this.data('timer'));
                        $this.data('timer', setTimeout(function(){
                        $this.removeData('timer');
                                console.log("Set id: " + id);
                                console.log("Set val: " + val);
                                submit(id, val);
                        }, delay));
                }); // togglebox click
                $('#error_popup').live('pagehide',function(event) {
                        location.reload();
                });
        } // e.target.id == 'control'
//        if (e.target.id == "schedule" ) {
//                console.log("Station Schedule");
//
//                // Submit function
//                function submit (name, duration, starttime, days, stations) {
//                        $.mobile.showPageLoadingMsg(); 
//                        var jsondata = { name: name, duration: duration, starttime: starttime, days: days, stations: stations };
//                        $.ajax({
//                                type: "POST",
//                                url: "/addschedule",
//                                data: JSON.stringify(jsondata),
//                                dataType: "json",
//                                //async: false,
//                                timeout: timeout, // in milliseconds
//                                success: function(data) {
//                                        // process data here
//                                        var status = '';
//                                        switch (data.result) {
//                                                case 'success':
//                                                        console.log("Success:" + data.result);
//                                console.log(data.message);
//                                                        $("#error_heading").text('Success'); 
//                                                        $("#error_content").text('Schedule added and enabled successfully.');
//                                                        $("#lnkInfo").click();
//                                                        console.log('click');
//                                                        status = '#';
//                                                        break;
//                                                case 'failure':
//                                                        console.log("Failure:" + data.result); 
//                                                        break;
//                                                default:
//                                                        $('div.fullscreen').show();
//                                                        $('div.' + data.result).show().empty().append(data.msg);
//                                        }
//        
//                                        $.mobile.hidePageLoadingMsg();
//                                },
//                                error: function(request, status, err) {
//                                        if (status == "timeout") {
//                                                console.log('timeout'); 
//                                                $("#popup_header").attr("data-theme","a").removeClass("ui-bar-b").addClass("ui-bar-a");
//                                                $("#error_heading").text('TIMEOUT');
//                                                $("#error_content").text('Request timed out, please refresh your browser.');
//                                                $("#lnkInfo").click();
//                                                console.log('click');
//                                                $.mobile.hidePageLoadingMsg();
//                                        }
//                                }
//                        });
//                } // function submit
//
//        } // e.target.id == 'category-+'
}); // document.ready
