


$(document).ready(function() {
	
  // change the default css to visible and hide it with js.
  $('.notes_form').css('visibility', 'visible');
  $('.notes_form').hide();
  	
  // change the default behavior of the new button to use the form on the index page and not call the new form.
  $('.new_button').click(function(evt){
  	$(".notes_button").css('height', '40px');
  	$(".notes_text_area").css('height', '200px');
  	$(".notes_form").slideDown();
  	evt.preventDefault();  	  
  });  // end new note
  
}); // end document ready