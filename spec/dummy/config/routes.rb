Rails.application.routes.draw do
  namespace :onboarding do
    resources :create_project, controller: :create_project
  end
end
