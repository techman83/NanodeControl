$(document).bind('pageinit', function(){
        // $(document).ready(function(){ <- This here does not work in jquery mobile. You will encounter hours of frustration until you learn this!

        // set initial states
        $('select').each(function() {
                if($(this).hasClass('on')) {
                        console.log('#' + this.id);
                        $('#' + this.id).val('on').slider("refresh");
                } else {
                        console.log(this.id);
                        $('#' + this.id).val('off').slider("refresh");
                }
        }); // togglebox foreach

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
                                                        // $('#' + id + '-' + attr).fadeIn('fast').animate({opacity:1},1000).fadeOut(1000);
                        				console.log("Success:" + data.result); 
                                                        status = '#' + attr;
                                                        break;
                                                case 'failure':
                        				console.log("Failure:" + data.result); 
                                                        // $('#' + id + '-failure').fadeIn('fast').animate({opacity:1},1000).fadeOut(1000);
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
}); // document.ready
