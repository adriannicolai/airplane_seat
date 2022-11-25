$(document).ready(function() {
  $(document)
    .on("submit", "#add_seat_form", submitAddSeatForm)
})

function submitAddSeatForm(e){
  e.preventDefault();
  let add_seat_form = $(this);

  $.post(add_seat_form.attr("Action"), add_seat_form.serialize(), function(add_seat_form_response){
    console.log('add_seat_form_response :>> ', add_seat_form_response);
  })
}