$(function() {
  var form = $('form#onboarding_main_form');
  if (!form.length) { return false; }
  var saveAndExitLink = form.closest('body').find('#save_and_exit');
  if (!saveAndExitLink.length) { return false; }
  saveAndExitLink.click(function() {
    var action = form.attr("action");
    form.attr("action", action + "?exit=true");
    form.submit();
  });
});