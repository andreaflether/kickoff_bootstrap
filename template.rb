=begin
Template Name: Kickoff - Bootstrap
Author: Andréa Alencar
Author URI: https://github.com/andreaflether
Instructions: $ rails new myapp -d <postgresql, mysql, sqlite3> -m template.rb -T
=end

def source_paths
  [File.expand_path(File.dirname(__FILE__))]
end

def add_gems
  gems_command = <<~RUBY
    # Custom gems for this application
    gem 'devise'
    gem 'name_of_person'
    gem 'simple_form'
  RUBY

  insert_into_file "Gemfile", 
    "#{gems_command}\n",
    before: "group :development, :test do"
end

def add_gem_groups
  dev_and_test_group = <<-RUBY
  gem 'annotate'
  gem 'better_errors'
  gem 'faker'
  gem 'rspec-rails', '~> 5.0.0'
  RUBY

  append_to_file "Gemfile",
    "\n#{dev_and_test_group}",
    after: "group :development, :test do"

  # Test group
  test_group = <<~RUBY
    group :test do
      gem 'capybara', '>= 3.26'
      gem 'database_cleaner'
      gem 'factory_bot_rails'
      gem 'rubocop-rails', require: false
      gem 'rubocop-rspec', require: false
      gem 'selenium-webdriver'
      gem 'shoulda-matchers'
      gem 'simplecov', require: false
      gem 'simplecov_json_formatter'
      gem 'webdrivers'
    end
  RUBY

  insert_into_file "Gemfile", 
    "#{test_group}\n",
    before: "# Windows does not include zoneinfo files, so bundle the tzinfo-data gem"

  dev_group = <<-RUBY
  gem 'bullet'
  gem 'query_diet'
  gem 'guard', '~> 2.15'
  gem 'guard-livereload', require: false
  gem 'rack-livereload'
  gem 'spring-commands-rspec'
  RUBY

  append_to_file "Gemfile",
    "\n#{dev_group}",
    after: "group :development do"
end

def add_users
  run "spring stop"
  # Install Devise
  generate "devise:install"

  # Configure Devise
  environment(nil, env: 'development') do
    # ActionMailer config
    "config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }"
  end

  route "root to: 'home#index'"

  # Create Devise User
  generate :devise, "User", "first_name", "last_name", "admin:boolean"

  # Set admin boolean to false by default
  in_root do
    migration = Dir.glob("db/migrate/*").max_by{ |f| File.mtime(f) }
    gsub_file migration, /:admin/, ":admin, default: false"
  end

  # name_of_person gem
  person_content = <<~RUBY
    has_person_name
  RUBY

  append_to_file "app/models/user.rb", 
    "#{person_content}\n",
    after: "class User < ApplicationRecord\n"
end

def add_livereload
  run "guard init livereload"

  environment(nil, env: 'development') do 
    # Rack Live-reload
    "config.middleware.insert_after ActionDispatch::Static, Rack::LiveReload"
  end
end

def add_simple_form
  # Install Simple Form and use Bootstrap as default framework
  generate "simple_form:install --bootstrap"
end

def copy_templates
  directory "app", force: true
  directory "lib", force: true
end

def add_app_packages
  run "yarn add jquery@3.6.0 bootstrap@4.6.0 toastr@2.1.4 @fortawesome/fontawesome-free@5.15.4"

  run "mkdir -p app/javascript/stylesheets"
  
  append_to_file "app/javascript/packs/application.js",
    <<~CODE
    \nrequire('bootstrap/dist/js/bootstrap.bundle.min')
    import toastr from 'toastr'
    global.toastr = toastr
    CODE

  append_to_file "app/javascript/packs/application.js",
    <<~CODE
    \nimport 'stylesheets/application'
    import '@fortawesome/fontawesome-free/css/all'
    CODE

  append_to_file "config/webpack/environment.js", 
    after: "const { environment } = require('@rails/webpacker')\n" do
      <<~CODE
        const webpack = require('webpack')

        environment.plugins.prepend('Provide',
          new webpack.ProvidePlugin({
            $: 'jquery/src/jquery',
            jQuery: 'jquery/src/jquery'
          })
        )
      CODE
    end
end

# Remove Application CSS
def remove_app_css
  remove_file "app/assets/stylesheets/application.css"
end

def tests_config
  # Generate boilerplate configuration files for RSpec
  generate "rspec:install"

  # Add bin/rspec command for Spring
  run "spring binstub rspec"

  tests_config = <<-RUBY
  # FactoryBot lint
  config.before(:suite) do
    FactoryBot.lint
  end

  # Run specs in random order to surface order dependencies
  config.order = :random
  RUBY

  # FB Lint creates each factory and catches any exceptions raised during the creation process
  append_to_file "spec/spec_helper.rb",
    "#{tests_config}\n",
    after: "RSpec.configure do |config|\n"
end

def add_simplecov
  # SimpleCov config
  simple_cov = <<~RUBY
    require 'simplecov'

    SimpleCov.start do
      add_group 'Models', 'app/models'
      add_group 'Controllers', 'app/controllers'
      add_group 'Helpers', 'app/helpers'
      add_filter 'config/'
      add_filter 'lib/'
      add_filter 'spec/'
    end
  RUBY
  
  prepend_to_file "spec/spec_helper.rb", "#{simple_cov}\n"
  gitignore_content = <<~EOS
    # Ignore SimpleCov Coverage
    /coverage
  EOS
  append_to_file ".gitignore", "\n#{gitignore_content}"
end

def add_shoulda_matchers
  shoulda_config = <<-RUBY
  Shoulda::Matchers.configure do |config|
    config.integrate do |with|
      with.test_framework :rspec
      with.library :rails
    end
  end
  RUBY

  append_to_file "spec/rails_helper.rb",
    "#{shoulda_config}\n",
    after: "RSpec.configure do |config|\n"
end

def add_database_cleaner
  append_to_file "spec/rails_helper.rb", 
    "require 'database_cleaner'",
    after: "# Add additional requires below this line. Rails is not loaded until this point!"

  db_cleaner_config = <<-RUBY
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
  RUBY

  append_to_file "spec/rails_helper.rb",
    "#{db_cleaner_config}\n",
    after: "RSpec.configure do |config|\n"
end

def add_foreman
  copy_file "Procfile"
end

def annotate
  generate "annotate:install"
  run "annotate"
end

def run_rubocop
  run "rubocop"
end

# Main setup
source_paths

add_gems
add_gem_groups

after_bundle do
  add_users
  add_livereload
  add_simple_form
  remove_app_css
  tests_config
  add_foreman
  copy_templates
  add_app_packages
  add_simplecov
  add_shoulda_matchers
  add_database_cleaner
  annotate
  run_rubocop

  # Migrate
  rails_command "db:create"
  rails_command "db:migrate"

  # Git
  git :init
  git add: "."
  git commit: %Q{ -m "Initial commit" }

  say
  say "Kickoff app successfully created! ✌️" , :green
  say
  say "Switch to your app by running:"
  say "  cd #{app_name}", :blue
  say
  say "  Then run:"
  say "     foreman start # Run Rails, Guard and webpack-dev-server", :blue
  say "  or:"
  say "     rails s # Run Rails only", :blue
end
