module NfgOnboarder
  # Ex usage on a view: NfgOnboarder::MastheadPresenter.new(onboarding_session, self)
  # This presenter allows us to manually overwrite the title bar caption and title
  # Through ruby instead of relying strictly on I18n incase there
  # is custom logic on the host app and more complex logic is needed to determine
  # what language to output for either the captioin or the title.
  class MastheadPresenter < NfgOnboarder::OnboarderPresenter
    def title_bar_caption
      I18n.t('title_bar.caption', scope: h.locale_namespace)
    end

    def title_bar_title
      I18n.t('title_bar.title', scope: h.locale_namespace, default: '')
    end
  end
end