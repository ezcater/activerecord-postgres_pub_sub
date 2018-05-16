# frozen_string_literal: true

require "rails/generators"
require "rails/generators/migration"
require "rails/generators/active_record"

module ActiveRecord
  module PostgresPubSub
    class NotifyOnInsertGenerator < Rails::Generators::Base
      include ActiveRecord::Generators::Migration

      source_root File.join(File.dirname(__FILE__), "templates")

      class_option :model_name, type: :string

      def create_migration_file
        migration_template("create_notify_on_insert_trigger.rb.erb",
                           "db/migrate/create_notify_on_#{table_name}_insert_trigger.rb")
      end

      private

      def model_name
        @model_name ||= options.fetch(:model_name)
      end

      def table_name
        @table_name ||= model_name.tableize.tr("/", "_")
      end

      def notification_name
        @notification_name || table_name.singularize
      end

      def table_module
        @module_name ||= model_name.deconstantize.underscore.tr("/", "_")
      end

      def model_title
        @model_title ||= table_name.camelize
      end
    end
  end
end
