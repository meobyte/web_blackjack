$(function() {
  $('#page-inner').on('click', '.ajaxify', onSubmitForm);
});

function onSubmitForm(event) {
  var $form = $(event.target).closest('form');
  var url = $form.attr('action');
  $.ajax({
      type: 'POST',
      url: url,
      success: function(data){
        $('#page-inner').html(data)
      }
    });
    return false;
}
