# NfgOnboarder

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'nfg_onboarder'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install nfg_onboarder

## Usage

Run the installer
```ruby
rails g nfg_onboarder:install
```

This should create the following files
```ruby
      create  db/migrate/20170605133220_create_onboarding_session.rb
      create  db/migrate/20170605133221_create_onboarding_related_object.rb
      create  app/models/onboarding/session.rb
      create  app/models/onboarding/related_object.rb
      create  app/controllers/onboarding/base_controller.rb
      insert  app/models/admin.rb
```

Then migrate the db

An association between the onboarding_sessions parent object (typically at the tenant level for a multi-tenant site) and the onboarding session needs to be created
Likely, you will add to the parent object the following

```ruby
has_many :onboarding_sessions, foreign_key: "entity_id", class_name: "Onboarding::Session"
```

Include the NfgOnboarding::OnboardableObject module on any object that will be built with the onboarder
```ruby
include NfgOnboarder::OnboardableObject
```

Add a namespacing to the routes file for onboarding
```ruby
  namespace :onboarding do

  end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).
