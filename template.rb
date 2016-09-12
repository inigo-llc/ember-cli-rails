# This script is used with the Ruby on Rails' new project generator:
#
#     rails new my_app -m path/to/this/template.rb
#
# For more information about the template API, see:
#    http://edgeguides.rubyonrails.org/rails_application_templates.html
#
# This template assumes you have followed the setup guide at:
# https://github.com/wildland/guides/#setting-up-your-development-enviroment
#
ruby_version = '2.3.1'
node_version = 'v4.5.0'
action_messages = []
branch = 'cleanup-updates'

# Initialize git repo
git :init
git add: '.'
git commit: "-m 'Initial commit.'"

# Download the most recent gitignore boilerplate
run "curl -o .gitignore 'https://raw.githubusercontent.com/wildland/trailhead/#{branch}/boilerplates/gitignore'"

# Remove normal readme
run 'rm README.rdoc'

# Download the most recent README boilerplate
run "curl -o README.md 'https://raw.githubusercontent.com/wildland/trailhead/#{branch}/boilerplates/readme'"
# Fill in README template
gsub_file 'README.md', /<app-name>/, "#{@app_name}"
gsub_file 'README.md', /<ruby-version>/, ruby_version
gsub_file 'README.md', /<node-version>/, node_version

# Download the most recent rubocop boilerplate
run "curl -o .rubocop.yml 'https://raw.githubusercontent.com/wildland/trailhead/#{branch}/boilerplates/rubocop'"

# Create ruby and node version files
create_file '.ruby-version' do
  ruby_version
end
create_file '.nvmrc' do
  node_version
end

# Update to latest patch version of rails
gsub_file 'gemfile', /gem 'rails', '/, "gem 'rails', '~>"

# kill un-needed gems

run "sed -i.bak '/jbuilder/d' Gemfile"

run "sed -i.bak '/sass-rails/d' Gemfile"
run "sed -i.bak '/Use SCSS/d' Gemfile"

run "sed -i.bak '/uglifier/d' Gemfile"
run "sed -i.bak '/Use Uglifier/d' Gemfile"

run "sed -i.bak '/turbolinks/d' Gemfile"
run "sed -i.bak '/Turbolinks makes/d' Gemfile"

# cleanup
run 'rm Gemfile.bak'

inject_into_file 'Gemfile', after: "source 'https://rubygems.org'" do
  "\ngem 'dotenv-rails', groups: [:development, :test], require: 'dotenv/rails-now'"
end

# Install production gems
gem_group :production do
  gem 'rails_12factor'
end

gem 'pg'
# Install Squeel
gem 'squeel'
gem 'factory_girl_rails'
gem 'mailcatcher'
gem 'puma'
gem "ember-cli-rails", '~> 0.8.0'

# Install development and test gems
gem_group :development, :test do
  gem 'wildland_dev_tools', '~>0.7.0', git: 'git+ssh://git@github.com/wildland/wildland_dev_tools.git'
  gem 'annotate'
  gem 'brakeman'
  gem 'faker'
  gem 'pry-rails'
  gem 'pry-byebug'
  gem 'rspec-rails'
  gem 'rubocop'
end

# Install gems using bundler
run 'bundle install'

# Setup annotate gem
run 'rails generate annotate:install'

# Setup rspec
run 'rails generate rspec:install'
# Allow support files to be loaded
gsub_file 'spec/rails_helper.rb', /# Dir\[Rails\.root\.join/, 'Dir[Rails.root.join'
# Remove test folder
run 'rm -rf test/'

# Download the most recent buildpack boilerplate
run "curl -o .buildpacks 'https://raw.githubusercontent.com/wildland/trailhead/#{branch}/boilerplates/buildpacks'"
# Fill in README template
gsub_file '.buildpacks', /<app-name>/, "#{@app_name}"

# Download the most recent app.json boilerplate
run "curl -o app.json 'https://raw.githubusercontent.com/wildland/trailhead/#{branch}/boilerplates/app.json'"
# Fill in README template
gsub_file 'app.json', /<app-name>/, "#{@app_name}"

# Download the most recent app.json boilerplate
run "curl -o .env 'https://raw.githubusercontent.com/wildland/trailhead/#{branch}/boilerplates/env'"

# Download the most recent Procfile boilerplate
run "curl -o Procfile 'https://raw.githubusercontent.com/wildland/trailhead/#{branch}/boilerplates/Procfile'"


# Download the most recent Puma config boilerplate
run "curl -o config/puma.rb 'https://raw.githubusercontent.com/wildland/trailhead/#{branch}/boilerplates/puma_config.rb'"

# Download the most recent Ember launcher boilerplate
run "curl -o bin/ember 'https://raw.githubusercontent.com/wildland/trailhead/#{branch}/boilerplates/bin_ember'"
run 'chmod u+x bin/ember'


# Download the most recent Mailcatcher launcher boilerplate
run "curl -o bin/mailcatcher 'https://raw.githubusercontent.com/wildland/trailhead/#{branch}/boilerplates/bin_mailcatcher'"
run 'chmod u+x bin/mailcatcher'

# Download the most recent log launcher boilerplate
run "curl -o bin/log 'https://raw.githubusercontent.com/wildland/trailhead/#{branch}/boilerplates/bin_log'"
run 'chmod u+x bin/log'

# Ember cli
run "curl -o config/initializers/ember.rb 'https://raw.githubusercontent.com/wildland/trailhead/#{branch}/boilerplates/ember-cli-config.rb'"
run 'mkdir app/views/ember_cli/ && mkdir app/views/ember_cli/ember'
run "curl -o app/views/ember_cli/ember/index.html.erb 'https://raw.githubusercontent.com/wildland/trailhead/#{branch}/boilerplates/ember-cli-index.erb'"

inject_into_file 'config/secrets.yml', after: 'production:' do
  "\n  wildland_server_status: <%= ENV['WILDLAND_STATUS_BAR'] %>"
end

environment 'config.action_mailer.raise_delivery_errors = true', env: 'development'
environment 'config.action_mailer.delivery_method = :smtp', env: 'development'
environment 'config.action_mailer.smtp_settings = { address: "localhost", port: 1025 }', env: 'development'
environment 'config.action_mailer.default_options = { from: "no-reply@example.org" }', env: 'development'

inject_into_file 'app/controllers/application_controller.rb', after: 'class ApplicationController < ActionController::Base' do
  "\n  force_ssl if Rails.env.production?\n"
end

# Setup factory_girl
run "curl -o lib/tasks/demo.rake 'https://raw.githubusercontent.com/wildland/trailhead/#{branch}/boilerplates/demo.rake'"

# Initialize the database
run 'rake db:create'
run 'rake db:migrate'

inject_into_file 'app/controllers/application_controller.rb', after: 'class ApplicationController < ActionController::Base' do
  "\n  force_ssl if Rails.env.production?\n"
end

# Add ember controller
run "curl -o app/controllers/ember_application_controller.rb 'https://raw.githubusercontent.com/wildland/trailhead/#{branch}/boilerplates/ember_application_controller.rb'"

# Remove Comments and empty lines
gsub_file 'config/routes.rb', /^(  #.*\n)|(\n)/, ''
inject_into_file 'config/routes.rb', after: 'do' do
  "\n"
end
route "mount_ember_app :frontend, to: '/', controller: 'ember_application'"
route '# Clobbers all routes, Keep this as the last route in the routes file'

ember_app = 'app-ember'

# create ember-cli app
run "ember new #{ember_app}"

# Remove the sub-git project created
run "rm -rf #{ember_app}/.git/"
run "rm #{ember_app}/.ember-cli"

# Correct minor version bugs
inside "#{ember_app}" do
  gsub_file 'bower.json', /"jquery": "\^1.11.3",/, '"jquery": "1.11.3",'
  run 'bower install'
end

create_file "#{ember_app}/.nvmrc" do
  node_version
end

# Create the file that sets the default ember serve options (like the proxy)
# Add ember controller
run "curl -o #{ember_app}/.ember-cli 'https://raw.githubusercontent.com/wildland/trailhead/#{branch}/boilerplates/ember-cli'"

inject_into_file 'config/routes.rb',
                 before: '  # Clobbers all routes, Keep this as the last route in the routes file' do
  "\n\n"
end

# Ember Deployment (ember-cli-rails)
inside "#{ember_app}" do
  run 'ember install ember-cli-rails-addon@0.7.0'
end

run "mkdir #{ember_app}/app/adapters/"
run "curl -o #{ember_app}/app/adapters/application.js 'https://raw.githubusercontent.com/wildland/trailhead/#{branch}/boilerplates/adapter.js'"
run "mkdir #{ember_app}/app/serializers/"
run "curl -o #{ember_app}/app/serializers/application.js 'https://raw.githubusercontent.com/wildland/trailhead/#{branch}/boilerplates/serializer.js'"

###
# Recipes
###

# api_me installation
gem 'api_me', '~>0.7.0'
run 'bundle install'
run 'rails g api_me:install'

# Token Authentication Installation and Setup (token_authenticate_me and ember-authenticate-me)
gem 'token_authenticate_me', '~>0.4.3'
run 'bundle install'
run 'rails g token_authenticate_me:install'
run 'rake db:migrate'

run 'rails g api_me:policy user username email password password_confirmation'
#inject_into_class 'app/policies/user_policy.rb', UserPolicy do
#  "  def create?\n    true\n  end\n"
#end

# Ember part
inside "#{ember_app}" do
  run 'ember install ember-authenticate-me@0.4.0'
  run 'ember generate user'
  run 'ember g ember-authenticate-me'
end

git add: '.'
git commit: "-m 'Project #{@app_name} initialized'"

puts <<-MESSAGE

***********************************************************

Your ember-cli app is located at: '#{@app_path}/#{ember_app}'
see: https://github.com/stefanpenner/ember-cli

***********************************************************

MESSAGE

puts <<-MESSAGE
***********************************************************
Actions:
MESSAGE

action_messages.each do |message|
  puts '**************'
  puts message
  puts '**************'
end
