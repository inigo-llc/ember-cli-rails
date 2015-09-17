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
ruby_version = '2.2.2'
node_version = 'v4.0.0'
action_messages = []

# Initialize git repo
git :init
git add: '.'
git commit: "-m 'Initial commit.'"

# Download the most recent gitignore boilerplate
run "curl -o .gitignore 'https://raw.githubusercontent.com/wildland/ember-cli-rails/master/gitignore_boilerplate'"

# Remove normal readme
run 'rm README.rdoc'

# Download the most recent README boilerplate
run "curl -o README.md 'https://raw.githubusercontent.com/wildland/ember-cli-rails/master/readme_boilerplate'"
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

# Install production gems
gem_group :production do
  gem 'rails_12factor'
end
# Install Squeel
gem 'squeel'
gem 'factory_girl_rails'

# Install development and test gems
gem_group :development, :test do
  gem 'wildland_dev_tools', '>=0.1.0', git: 'https://github.com/wildland/wildland_dev_tools.git'
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
route "get '(*path)', to: 'ember_application#index'"
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

# Setup smartcd to prepend  ./node_modules/.bin to our path when we enter the ember application folder
file "#{ember_app}/.bash_enter", <<-FILE
########################################################################
# smartcd enter
#
# This is a smartcd script.  Commands you type will be run when you
# enter this directory.  The string __PATH__ will be replaced with
# the current path.  Some examples are editing your $PATH or creating
# a temporary alias:
#
#     autostash PATH=__PATH__/bin:$PATH
#     autostash alias restart="service stop; sleep 1; service start"
#
# See http://smartcd.org for more ideas about what can be put here
########################################################################

autostash PATH=__PATH__/node_modules/.bin:$PATH
FILE

route <<-FILE
namespace :api do
    get :csrf, to: 'csrf#index'
  end
FILE
inject_into_file 'config/routes.rb',
                 before: '  # Clobbers all routes, Keep this as the last route in the routes file' do
  "\n\n"
end

file 'app/controllers/api/csrf_controller.rb', <<-FILE
class Api::CsrfController < ApplicationController
  skip_before_action :authenticate, only: [:index]

  def index
    render json: { request_forgery_protection_token => form_authenticity_token }.to_json
  end
end
FILE

inside "#{ember_app}" do
  run 'npm install  --save-dev rails-csrf'
end

file "#{ember_app}/app/routes/application.js", <<-FILE
import Ember from 'ember';

export default Ember.Route.extend({
  beforeModel: function() {
    return this.csrf.fetchToken();
  }
});
FILE

inject_into_file "#{ember_app}/app/app.js", after: 'loadInitializers(App, config.modulePrefix);' do
  "\nloadInitializers(App, 'rails-csrf');"
end

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
