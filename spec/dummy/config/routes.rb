Rails.application.routes.draw do
  namespace :onboarding do
    namespace :create_campaign do
      resources :recruit_fundraisers, controller: :recruit_fundraisers
    end
    resources :create_project, controller: :create_project
  end
end
