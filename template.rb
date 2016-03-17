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
ruby_version = '2.2.3'
node_version = 'v5.4.0'
action_messages = []
branch = 'master'

# Initialize git repo
git :init
git add: '.'
git commit: "-m 'Initial commit.'"

# Download the most recent gitignore boilerplate
run "curl -o .gitignore 'https://raw.githubusercontent.com/wildland/ember-cli-rails/#{branch}/gitignore_boilerplate'"

# Remove normal readme
run 'rm README.rdoc'

# Download the most recent README boilerplate
run "curl -o README.md 'https://raw.githubusercontent.com/wildland/ember-cli-rails/#{branch}/readme_boilerplate'"
# Fill in README template
gsub_file 'README.md', /<app-name>/, "#{@app_name}"
gsub_file 'README.md', /<ruby-version>/, ruby_version
gsub_file 'README.md', /<node-version>/, node_version

# Download the most recent rubocop boilerplate
run "curl -o .rubocop.yml 'https://raw.githubusercontent.com/wildland/ember-cli-rails/master/rubocop_boilerplate'"

# Create ruby and node version files
create_file '.ruby-version' do
  ruby_version
end
create_file '.nvmrc' do
  node_version
end

create_file 'Procfile' do

end

# Update to latest patch version of rails
gsub_file 'gemfile', /gem 'rails', '/, "gem 'rails', '~>"

# kill un-needed gems

run "sed -i.bak '/jbuilder/d' Gemfile"

run "sed -i.bak '/sass-rails/d' Gemfile"
run "sed -i.bak '/Use SCSS/d' Gemfile"

run "sed -i.bak '/uglifier/d' Gemfile"
run "sed -i.bak '/Use Uglifier/d' Gemfile"
# cleanup
run 'rm Gemfile.bak'

inject_into_file 'Gemfile', after: "source 'https://rubygems.org'" do
  "\ngem 'dotenv-rails', groups: [:development, :test], require: 'dotenv/rails-now'"
end

# Install production gems
gem_group :production do
  gem 'rails_12factor'
end
# Install Squeel
gem 'squeel'
gem 'factory_girl_rails'
gem 'mailcatcher'
gem 'puma'
gem "ember-cli-rails", '~> 0.7.1'

# Install development and test gems
gem_group :development, :test do
  gem 'wildland_dev_tools', '>=0.1.0', git: 'git+ssh://git@github.com/wildland/wildland_dev_tools.git'
  gem 'annotate'
  gem 'brakeman'
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

# Add heroku buildpacks for heroku deployment
file '.buildpacks', <<-FILE
https://github.com/heroku/heroku-buildpack-ruby.git
https://github.com/heroku/heroku-buildpack-nodejs.git
FILE

# Setup default app.json for heroku deployments
file 'app.json', <<-FILE
{
  "name": "#{@app_name}",
  "scripts": {
    "postdeploy": "rake db:setup && rake demo:seed"
  },
  "env": {
    "LANG": {
      "required": true
    },
    "RACK_ENV": {
      "required": true
    },
    "RAILS_ENV": {
      "required": true
    },
    "RAILS_SERVE_STATIC_FILES": {
      "required": true
    },
    "SECRET_KEY_BASE": {
      "required": true
    },
    "NPM_CONFIG_PRODUCTION": {
      "required": true
    },
    "WILDLAND_STATUS_BAR": "development"
  },
  "addons": [
    "heroku-postgresql",
    "sendgrid:starter"
  ],
  "buildpacks": [
    {
      "url": "https://github.com/heroku/heroku-buildpack-nodejs"
    },
    {
      "url": "https://github.com/heroku/heroku-buildpack-ruby"
    }
  ]
}
FILE

file '.env', <<-FILE
SKIP_EMBER=true
FILE

# Setup Procfile to handle auto starting all entire app all at once
file 'Procfile', <<-FILE
web: bundle exec puma -C config/puma.rb
log: bin/log
mailcatcher: bin/mailcatcher
ember: bin/ember
FILE


# Setup puma
file 'config/puma.rb', <<-FILE
workers Integer(ENV['WEB_CONCURRENCY'] || 2)
threads_count = Integer(ENV['MAX_THREADS'] || 5)
threads threads_count, threads_count

preload_app!

rackup      DefaultRackup
port        ENV['PORT']     || 5000
environment ENV['RACK_ENV'] || 'development'

on_worker_boot do
  # Worker specific setup for Rails 4.1+
  # See: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#on-worker-boot
  ActiveRecord::Base.establish_connection
end
FILE

# Setup ember launcher script
file 'bin/ember', <<-FILE
#!/bin/sh
if [ ${RACK_ENV:=development} == "development" ]; then
  cd app-ember
  ember server --proxy http://localhost:5000 --port 4200
fi
FILE
run 'chmod u+x bin/ember'

# Setup mailcatcher launcher script
file 'bin/mailcatcher', <<-FILE
#!/bin/sh
if [ ${RACK_ENV:=development} == "development" ]; then
  bundle exec mailcatcher -f
fi
FILE
run 'chmod u+x bin/mailcatcher'

file 'config/initializers/ember.rb', <<-FILE
EmberCli.configure do |c|
  c.app :frontend, path: './app-ember'
end
FILE

file 'app/views/ember_cli/ember/index.html.erb', <<-FILE
<%= render_ember_app ember_app do |head, body| %>
  <% head.append do %>
    <%= csrf_meta_tags %>
  <% end %>
  <% body.append do %>
    <% if Rails.application.secrets.wildland_server_status == 'development' %>
      <div id="pipeline-flag">
        <div class="development-flag">
          <p>Development</p>
        </div>
      </div>
    <% end %>
    <% if Rails.application.secrets.wildland_server_status == 'staging' %>
      <div id="pipeline-flag">
        <div class="staging-flag">
          <p>Staging</p>
        </div>
      </div>
    <% end %>
  <% end %>
<% end %>
FILE

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
file 'spec/support/factory_girl.rb', <<-FILE
RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end
FILE

# Add seed task
create_file 'lib/tasks/demo.rake' do
  %q(require 'factory_girl'

  namespace :demo do
    task seed: :environment do
      # Add any seed information here
    end
  end)
end

# Initialize the database
run 'rake db:create'
run 'rake db:migrate'

inject_into_file 'app/controllers/application_controller.rb', after: 'class ApplicationController < ActionController::Base' do
  "\n  force_ssl if Rails.env.production?\n"
end

# Add ember controller
file 'app/controllers/ember_application_controller.rb', <<-FILE
class EmberApplicationController < ApplicationController
  def index
    render file: 'public/index.html'
  end
end
FILE

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

create_file "#{ember_app}/.nvmrc" do
  node_version
end

# Create the file that sets the default ember serve options (like the proxy)
file "#{ember_app}/.ember-cli", <<-FILE
{
  /**
    Ember CLI sends analytics information by default. The data is completely
    anonymous, but there are times when you might want to disable this behavior.

    Setting `disableAnalytics` to true will prevent any data from being sent.
  */
  "disableAnalytics": false,
  "proxy": "http://localhost:3000"
}
FILE

inject_into_file 'config/routes.rb',
                 before: '  # Clobbers all routes, Keep this as the last route in the routes file' do
  "\n\n"
end

# Ember Deployment (ember-cli-rails)
inside "#{ember_app}" do
  run 'ember install ember-cli-rails-addon@0.7.0'
end

file "#{ember_app}/app/adapters/application.js", <<-FILE
import AuthenticatedAdapter from 'ember-authenticate-me/adapters/authenticated';
import ENV from '../config/environment';

export default AuthenticatedAdapter.extend({
  namespace: ENV.apiNamespace || 'api/v1',
  coalesceFindRequests: true,
});
FILE

file "#{ember_app}/app/serializers/application.js", <<-FILE
import DS from 'ember-data';
 
export default DS.ActiveModelSerializer.extend({
  attrs: {
    createdAt: { serialize: false },
    updatedAt: { serialize: false },
  },
});
FILE

###
# Recipes
###

# api_me installation
gem 'api_me'
run 'bundle install'
run 'rails g api_me:install'

# Token Authentication Installation and Setup (token_authenticate_me and ember-authenticate-me)
gem 'token_authenticate_me', '>=0.4.2'
run 'bundle install'
run 'rails g token_authenticate_me:install user'
run 'rake db:migrate'
inject_into_file 'app/controllers/application_controller.rb', before: 'class' do
  "require 'token_authenticate_me/controllers/token_authenticateable'\n"
end
inject_into_file 'app/controllers/application_controller.rb', after: 'with: :exception' do
  "\n  include TokenAuthenticateMe::Controllers::TokenAuthenticateable\n"
end
run 'rails g api_me:policy user username email password password_confirmation'
#inject_into_class 'app/policies/user_policy.rb', UserPolicy do
#  "  def create?\n    true\n  end\n"
#end
run 'rails g api_me:filter user'
run 'user username email created_at updated_at'

# Ember part
inside "#{ember_app}" do
  run 'ember install  ember-authenticate-me'
  run 'ember generate user'
end

# Ember Authorization (ember-sanctify)
inside "#{ember_app}" do
  run 'ember install ember-sanctify'
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
