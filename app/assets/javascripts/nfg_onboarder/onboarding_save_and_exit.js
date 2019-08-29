if(typeof NfgOnboarder == 'undefined') { // this checks for null and undefined
  window.NfgOnboarder = {};
  NfgOnboarder.OnboardingSaveAndExit = class OnboardingSaveAndExit {
    constructor(link) {
      this.link = link;
      this.form = $('form#onboarding_main_form');
      this.form.on('submit', e => {
        this.link.addClass('disabled');
      });
      this.link.on('click', e => {
        NfgOnboarder.submitOnboardingForm(this.form);
        return false
      });
    }
  };

  NfgOnboarder.submitOnboardingForm = function (form) {
    const action = form.attr("action");
    form.attr("action", action + "?exit=true");
    form.submit();
  };

  NfgOnboarder.submitOnboardingExitForm = function () {
    let form = $('form#onboarding_main_form');
    NfgOnboarder.submitOnboardingForm(form)
  };

  $(document).on('turbolinks:load', function () {
    let link = $('body.onboarding-email_creator, body.onboarding-mailing_creator').find('#save_and_exit');
    if (!link.length) {
      return;
    }
    new NfgOnboarder.OnboardingSaveAndExit(link);
  });
}
