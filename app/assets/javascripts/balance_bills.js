

function setup_patient_select(){
	$('#provider_id').change(function(){
		$.get($('#new_balance_bill').attr('action'), $('#new_balance_bill').serialize());
	});

	$('#patient_id').change(function(){
		$.get($('#new_balance_bill').attr('action'), $('#new_balance_bill').serialize());
	});
};



$(document).ready(function() {
	setup_patient_select();

}); // end document ready