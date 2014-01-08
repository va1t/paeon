/**********************************************
* index page js functions
***********************************************/

// setup to handle group and provider selection in insurance billings index
function setup_group_id(){
  $('#sessions_group_id').change(function(){
      $('.table_data').hide();
      $.get($('#sessions_group_form').attr('action'), $('#sessions_group_form').serialize() );
  });
  $('#sessions_provider_id').change(function(){
      $('.table_data').hide();
      $.get($('#sessions_group_form').attr('action'), $('#sessions_group_form').serialize() );
  });
}; // end setup_billings_group_id


// setup to handle patient selection in insurance billings index
function setup_patient_id(){
  $('#sessions_patient_id').change(function(){
  	  data = $(this).serialize() + '&' + $('#sessions_group_form').serialize();
      $.get($('#sessions_patient_form').attr('action'), data );
  });
};  // end setup_billings_patient_id




$(document).ready(function() {

  setup_group_id();
  setup_patient_id();

});

