/**********************************************
* index page js functions 
***********************************************/

// setup to handle group and provider selection in insurance billings index 
function setup_group_id(){
  $('#group_id').change(function(){
      $('.form').hide();
      $('#provider_id').val("");
      $.get($('#invoice_maintenance_form').attr('action'), $('#invoice_maintenance_form').serialize() ) 
  });
  $('#provider_id').change(function(){
      $('.form').hide();
      $('#group_id').val("");
      $.get($('#invoice_maintenance_form').attr('action'), $('#invoice_maintenance_form').serialize() ) 
  }); 
}; // end setup_billings_group_id



$(document).ready(function() {
  
  setup_group_id();

});

