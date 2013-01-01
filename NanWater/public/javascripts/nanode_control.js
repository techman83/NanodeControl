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
        if (e.target.id == 'addstation') {
                console.log("Add Station"); 
                // toggle actions        
                $('form').submit(function(event) {
                        event.stopPropagation();
                        event.preventDefault();
                        function submit (name, url, category) {
                                $.mobile.showPageLoadingMsg(); 
                                console.log($(this)); 
                                
                                $.ajax({
                                        type: "POST",
                                        url: "/stations/:add",
                                        data: { stationname: name, stationurl: url, stationcategory: category },
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
                        console.log("Name: " + $('[name=name]').val());
                        console.log("Url: " + $('[name=stationurl]').val());
                        console.log("Category: " + $('[name=category]').val());
                        submit($('[name=name]').val(), $('[name=stationurl]').val(), $('[name=category]').val());
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
                                
                                $.ajax({
                                        type: "POST",
                                        url: "/stations/:" + id,
                                        data: { station: id, act: attr },
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
