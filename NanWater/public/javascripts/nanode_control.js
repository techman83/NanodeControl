$(document).on('pageshow',function(event, ui){
        if (event.target.id == 'control') {
                // set initial states
                $('select').each(function() {
                        if($(this).hasClass('on')) {
                                console.log(this.id + ' on');
                                $('#' + this.id).val('on').slider("refresh");
                        } else {
                                console.log(this.id + ' off');
                                $('#' + this.id).val('off').slider("refresh");
                        }
                }); // togglebox foreach
        }
});

$(document).on('pageinit', function(e){
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
                                        timeout: 500, // in milliseconds
                                        success: function(data) {
                                                // process data here
        					var status = '';
                                                switch (data.result) {
                                                        case 'success':
                                				console.log("Success:" + data.result); 
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
                                                        $("#lnkError").click();
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
                                        url: "/stations/:remove",
                                        data: JSON.stringify(jsondata),
                                        dataType: "json",
                                        //async: false,
                                        timeout: 500, // in milliseconds
                                        success: function(data) {
                                                // process data here
        					var status = '';
                                                switch (data.result) {
                                                        case 'success':
                                				console.log("Success:" + data.result); 
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
                                                        $("#lnkError").click();
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
                                        timeout: 500, // in milliseconds
                                        success: function(data) {
                                                // process data here
        					var status = '';
                                                switch (data.result) {
                                                        case 'success':
                                				console.log("Success:" + data.result); 
                                                                status = '#';
                                                                break;
                                                        case 'failure':
                                				console.log("Failure:" + data.result); 
                                                                
                                                                $("#lnkError").click();
                                			        console.log('click');
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
                                                        $("#lnkError").click();
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
                $('select').change(function() {
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
                                        timeout: 500, // in milliseconds
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
                                                        $("#lnkError").click();
                                			console.log('click');
                                                	$.mobile.hidePageLoadingMsg();
                                                }
                                        }
                                });
                        } // function submit
                        submit(this.id, this.value);
                }); // togglebox click
        	$('#error_popup').live('pagehide',function(event) {
        		location.reload();
        	});
        } // e.target.id == 'control'
}); // document.ready
