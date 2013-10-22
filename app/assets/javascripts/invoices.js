/**********************************************
* index page js functions 
***********************************************/

// setup to handle group and provider selection in insurance billings index 
function setup_group_id(){
  $('#group_id').change(function(){
      $('.list').hide();
      $('#provider_id').val("");
      $.get($('#invoice_list').attr('action'), $('#invoice_list').serialize() );
  });
  $('#provider_id').change(function(){
      $('.list').hide();
      $('#group_id').val("");
      $.get($('#invoice_list').attr('action'), $('#invoice_list').serialize() ); 
  }); 
}; // end setup_group_id



$(document).ready(function() {
  
  setup_group_id();

});

