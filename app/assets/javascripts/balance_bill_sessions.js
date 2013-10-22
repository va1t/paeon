
//setup the button to add balance bill detail to the balance bill screen
function setup_detail_add(){
  $('#balance_bill_session_add').click(function(evt){
	var address = $(this).attr("href");
	$.get(address, $('#new_form :input').serialize());
	evt.preventDefault();
	return false;
  });
	
}; // end of detail add


$(document).ready(function() {
  setup_detail_add();
}); // end document ready