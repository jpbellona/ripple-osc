/**
 * JS related functions and add-ons related to the OSC plugin configuration page.
 *
 * @author  Jon Bellona
 * @link 		http://jpbellona.com
 */

(function ($) {

	$(document).ready(function() { 
		
		//CLEAR button and functions
		$('input#osc_room').before('<div id="osc-room-remove" class="remove-wrapper"><span class="icon-remove-circle osc-remove"></span></div>');
		$('#osc-room-remove').click(function(e){
			$('input#osc_room').val('');
			e.preventDefault();
		});
		$('input#osc_port').before('<div id="osc-port-remove" class="remove-wrapper"><span class="icon-remove-circle osc-remove"></span></div>');
		$('#osc-port-remove').click(function(e){
			$('input#osc_port').val('');
			e.preventDefault();
		});
		$('input#osc_ip').before('<div id="osc-ip-remove" class="remove-wrapper"><span class="icon-remove-circle osc-remove"></span></div>');
		$('#osc-ip-remove').click(function(e){
			$('input#osc_ip').val('');
			e.preventDefault();
		});

		if (clientIP != undefined) {
			$('#osc_ip').after('<button id="osc-ip-paste" class="btn"><i class=""></i> Insert IP </button>');
			$('#osc-ip-paste').after('<span class="osc">' + clientIP + ' is your computer\'s IP address.</span>');

			// paste the clientIP in the textfield
			// check old IPs, append if not in current list
			$('#osc-ip-paste').click(function(e){
				var curIPs = $('#osc_ip').val();
				var IParr = curIPs.split(', ');
				if ($.inArray(clientIP, IParr) == -1) { 
					curIPs = (curIPs == '')? clientIP : curIPs + ', ' + clientIP;
					$('#osc_ip').val(curIPs);
				}
				e.preventDefault();
			});
		}

	});

})(jQuery);