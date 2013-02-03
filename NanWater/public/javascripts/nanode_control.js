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

$(document).on('pageinit', function(e){
        var timeout = 15000;
        if (e.target.id == 'categories') {
                console.log("Add/Remove Categories"); 
                // toggle actions        
                $('form').submit(function(event) {
                        console.log("Submit"); 
                        event.stopPropagation();
                        event.preventDefault();
                        function submit (data, action, url) {
                                $.mobile.showPageLoadingMsg(); 
                                console.log($(this));
                                var jsondata = { data: data };
                                $.ajax({
                                        type: "POST",
                                        url: url,
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
                                                	        $.mobile.hidePageLoadingMsg();
        		                                        location.reload();
                                                                status = '#';
                                                                break;
                                                        case 'failure':
                                				console.log("Failure:" + data.error);
                                                                  if ( data.error == "undefined") {
                                                                    $("#popup_header").attr("data-theme","a").removeClass("ui-bar-b").addClass("ui-bar-a");
                                                                    $("#error_heading").text('UNDEFINED');
                                                                    $("#error_content").text('Category name has been left blank.');
                                                                    $("#lnkInfo").click();
                                                                  };
                                                                  if ( data.error == "none_seleceted") {
                                                                    $("#popup_header").attr("data-theme","a").removeClass("ui-bar-b").addClass("ui-bar-a");
                                                                    $("#error_heading").text('None Seleceted');
                                                                    $("#error_content").text('A Category has not been seleceted.') 
                                                                    $("#lnkInfo").click();
                                                                  };
                                                                  if ( data.error == "station_associated") {
                                                                    $("#popup_header").attr("data-theme","a").removeClass("ui-bar-b").addClass("ui-bar-a");
                                                                    $("#error_heading").text('Station Associated'); 
                                                                    $("#error_content").text('At least one station is still associated with the category "' + data.category + '".') 
                                                                    $("#lnkInfo").click();
                                                                  };
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
                        switch ($(this).attr('id')) {
                          case 'removecategory':
                              var categories = [];
                              $(":checkbox:checked").each(function() { 
                                     console.log("Remove Category: " + $(this).attr("id"));
                                     categories.push($(this).attr("id"));
                              });
                              submit(categories, "remove", "/removecategory");
                              break;
                          case 'addcategory':
                              console.log($('[name=name]').val());
                              submit($('[name=name]').val(),"add","/addcategory")
                              break;
                          default:
                              // some sort error handling here
                        }

                        console.log($(this).attr('id'));

                }); // togglebox click
            }; // categories
        if (e.target.id == 'removestation') {
                console.log("Remove Station"); 
                // toggle actions        
                $('form').submit(function(event) {
                        console.log("Submit"); 
                        event.stopPropagation();
                        event.preventDefault();
                        function submit (ids) {
                                $.mobile.showPageLoadingMsg(); 
                                console.log($(this)); 
                                var jsondata = { stations: ids };
                                
                                $.ajax({
                                        type: "POST",
                                        url: "/removestations",
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
                                                	        $.mobile.hidePageLoadingMsg();
        		                                        location.reload();
                                                                status = '#';
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
                        var stations = [];
                        $(":checkbox:checked").each(function() { 
                                console.log("Remove Station: " + $(this).attr("id"));
                                stations.push($(this).attr("id"));
                        });
                        submit(stations);
                }); // togglebox click
        	$('#error_popup').live('pagehide',function(event) {
        		location.reload();
                        return false;
        	});
        } // e.target.id == 'add'
        if (e.target.id == 'addstation') {
                console.log("Add Station"); 
                // toggle actions        
                $('form').submit(function(event) {
                        event.stopPropagation();
                        event.preventDefault();
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
                                				console.log("Success:" + data.result); 
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
                        console.log("Name: " + $('[name=name]').val());
                        console.log("Url: " + $('[name=stationurl]').val());
                        console.log("Category: " + $('[name=category]').val());
                        console.log("Type: " + $('[name=type]').val());
                        submit($('[name=name]').val(), $('[name=stationurl]').val(), $('[name=category]').val(), $('[name=type]').val());
                }); // togglebox click
        	$('#error_popup').live('pagehide',function(event) {
        		location.reload();
                        return false;
        	});
        } // e.target.id == 'add'
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
        if (e.target.id == "schedule" ) {
                console.log("Station Schedule");

                // Submit function
                function submit (name, duration, starttime, days, stations) {
                        $.mobile.showPageLoadingMsg(); 
                        var jsondata = { name: name, duration: duration, starttime: starttime, days: days, stations: stations };
                        $.ajax({
                                type: "POST",
                                url: "/addschedule",
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
                                console.log(data.message);
                                                        $("#error_heading").text('Success'); 
                                                        $("#error_content").text('Schedule added and enabled successfully.');
                                                        $("#lnkInfo").click();
                                			console.log('click');
                                                        status = '#';
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

                // Schedule
                $("form[id='schedule']").submit(function(event) {
                        event.stopPropagation();
                        event.preventDefault();
                        var days = [];
                        $(":checkbox:checked[id^='checkbox']").each(function() { 
                             days.push($(this).val());
                        });
                        var stations = [];
                        $(":checkbox:checked[id^='station-']").each(function() { 
                             stations.push($(this).attr("name"));
                        });
                        var name = $('[name=name]').val();
                        var duration = $('[name=duration]').val();
                        var starttime = $('[name=starttime]').val();
                        console.log("Submit: " + name + ", " + duration + ", " + starttime + ", [" + days + "], [" + stations + "]");
                        submit(name, duration, starttime, days, stations);
                });
                 
                // Set station popups
                $("form[id^='station_select-']").submit(function(event) {
                        event.stopPropagation();
                        event.preventDefault();
                        $("#" + this.id).popup("close")
                });
        } // e.target.id == 'category-+'
}); // document.ready
