Rails.application.routes.draw do
  mount NfgOnboarder::Engine => "/onboarding"
  namespace :onboarding do
    resources :create_project, controller: :create_project
  end
end
