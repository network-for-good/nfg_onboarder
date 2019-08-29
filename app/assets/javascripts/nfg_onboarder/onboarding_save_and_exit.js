if(typeof NfgOnboarder == 'undefined') { // this checks for null and undefined
  window.NfgOnboarder = {};

  NfgOnboarder.submitOnboardingForm = function (form) {
    const action = form.attr("action");
    form.attr("action", action + "?exit=true");
    form.submit();
  };

  NfgOnboarder.submitOnboardingExitForm = function () {
    let form = $('form#onboarding_main_form');
    NfgOnboarder.submitOnboardingForm(form)
  };
}
