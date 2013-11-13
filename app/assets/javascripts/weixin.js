//= require jquery
//= require jquery_ujs


function goto(url, user_name)
{
	if(user_name != ""){
		window.location.href = url + "?user_name=" + user_name ;
	}
	else{
		window.location.href = url;
	}
}

function goto_nav_page(user_name)
{
	goto("/phone_shells/nav.html", user_name);
}

function goto_machine_page(user_name)
{
	goto("/phone_shells/select_machine.html", user_name);
}

function goto_template_page(user_name)
{
	goto("/phone_shells/select_template.html", user_name);
}

function goto_shell_page(user_name) {
	goto("/phone_shells/select_shell.html", user_name)
}

function goto_address_page(user_name)
{
	goto("/phone_shells/address.html", user_name);
}

function goto_confirm_page(user_name, order_id)
{
	location.href = "/phone_shells/confirm.html?user_name=" + user_name + "&order_id=" + order_id;
}

function goto_express_page(user_name, order_id)
{
	location.href = "/phone_shells/express.html?user_name=" + user_name + "&order_id=" + order_id;
}

function goto_query_my_order_page(user_name)
{
	goto("/phone_shells/query_my_order.html", user_name);
}

function goto_pay_page(order_id)
{
	goto("/phone_shells/pay.html?order_id=" + order_id, "");    
}


function save_current_page_state(user_name, data, callback)
{
	$.getJSON( "/phone_shells/save_current_page_state.json" , {"user_name":user_name, "data":data} ,
	function( data ) {
		callback(user_name);
		if ( data .result == 0 )
		{
			return true ;
		} else
		{
			return false;
		}
	});
}

function complete_order(user_name, address, callback)
{
	var order_id = -2;

	$.getJSON( "/phone_shells/complete.json" , {"user_name":user_name, "address":address} ,
	function( data ) {
		callback(user_name, data.order_id);
		if ( data .result == 0 )
		{

		} else
		{
				
		}
	});

};

$(function(){
	$("input[type=text]").click(function(){
		$(this).select();
	});
	
	$(".btn.history").click(function(){
		history.back();
	});

});