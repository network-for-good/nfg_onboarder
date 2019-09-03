if(typeof NfgOnboarder == 'undefined') { // this checks for null and undefined
  window.NfgOnboarder = {};

  NfgOnboarder.submitOnboardingExitForm = function () {
    let form = $('form#onboarding_main_form');
    const action = form.attr("action");
    form.attr("action", action + "?exit=true");
    form.submit();
  };
}
