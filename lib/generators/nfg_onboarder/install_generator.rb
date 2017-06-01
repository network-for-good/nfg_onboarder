require 'rails/generators/base'
require 'rails/generators/active_record'

module NfgOnboarder
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      include Rails::Generators::Migration
      extend ActiveRecord::Generators::Migration

      def self.next_migration_number(dirname)
        ActiveRecord::Generators::Base.next_migration_number(dirname)
      end

      source_root File.expand_path('../templates', __FILE__)

      def copy_migrations
        migration_template "migrations/create_onboarding_session.rb", "db/migrate/create_onboarding_session.rb"
        migration_template "migrations/create_onboarding_related_object.rb", "db/migrate/create_onboarding_related_object.rb"
      end

      def create_onboarding_session_model
        create_file "app/models/onboarding/session.rb", <<-FILE
class Onboarding::Session < NfgOnboarder::Session

end
        FILE
      end

      def create_related_records_model
        create_file "app/models/onboarding/related_records.rb", <<-FILE
class Onboarding::RelatedRecord < NfgOnboarder::RelatedRecord

end
        FILE
      end

      def create_onboarding_controller
        create_file "app/controllers/onboarding/base_controller.rb", <<-FILE
class Onboarding::BaseController < NfgOnboarder::BaseController

end
        FILE
      end

      def add_onboardable_to_admin
        inject_into_file "app/models/admin.rb", after: "< ActiveRecord::Base\n" do <<-STRING
  include NfgOnboarder::Onboardable
        STRING
        end
      end
    end
  end

end