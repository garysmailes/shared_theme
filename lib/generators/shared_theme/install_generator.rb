# frozen_string_literal: true

require "rails/generators"

module SharedTheme
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("install/templates", __dir__)
      desc "Create site.css without replacing an existing site's customisations."

      def create_site_stylesheet
        relative_path = "app/assets/stylesheets/site.css"
        destination = File.join(destination_root, relative_path)

        # Protect local customisations, including when --force is supplied.
        if File.exist?(destination) || File.symlink?(destination)
          say_status :skip, "#{relative_path} already exists; left unchanged", :yellow
          return
        end

        copy_file "site.css", relative_path
      end
    end
  end
end
