/************************************
* index page js
*************************************/

function setup_selects(){
  $('#reporting_category_id').change(function(){
      $.get($('#reporting_category').attr('action'), $('#reporting_category').serialize() );
  });
  $('#reporting_item_id').change(function(){
      $('.table_data').hide();
      $.get($('#reporting_items').attr('action'), $('#reporting_items').serialize() );
  });
}; // end setup_billings_group_id


// activate the js on the page
$(document).ready(function() {

  setup_selects();


});
