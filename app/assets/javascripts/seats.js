$(document).ready(function() {
  $(document)
    .on("submit", "#add_seat_form", submitAddSeatForm);
})

function submitAddSeatForm(e){
  e.preventDefault();
  let add_seat_form = $(this);

  $.post(add_seat_form.attr("Action"), add_seat_form.serialize(), function(add_seat_form_response){
    if (add_seat_form_response.status){
      $("#airplane_seats").text(JSON.stringify(add_seat_form_response.result.airplane_seats));
      $("#unboarded_passengers").text(add_seat_form_response.result.unboarded_passengers)
    }
    else{
      if (add_seat_form_response.error){
        alert(add_seat_form_response.error);
      }
    }
  })
}