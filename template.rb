# This script is used with the Ruby on Rails' new project generator:
#
#     rails new my_app -m path/to/this/template.rb
#
# For more information about the template API, see:
#    http://edgeguides.rubyonrails.org/rails_application_templates.html
#
# This template assumes you have followed the setup guide at:
# https://github.com/inigo-llc/guides/#setting-up-your-development-enviroment
#
ruby_version = '2.1.5'
node_version = '0.10.32'
action_messages = []

# Initialize git repo
git :init
git add: '.'
git commit: "-m 'Initial commit.'"

# Download the most recent gitignore boilerplate
run "curl -o .gitignore 'https://raw.githubusercontent.com/inigo-llc/ember-cli-rails/master/gitignore_boilerplate'"

# Remove normal readme
run 'rm README.rdoc'

# Download the most recent README boilerplate
run "curl -o README.md 'https://raw.githubusercontent.com/inigo-llc/ember-cli-rails/master/readme_boilerplate'"
# Fill in README template
gsub_file 'README.md', /<app-name>/, "#{@app_name}"
gsub_file 'README.md', /<ruby-version>/, ruby_version
gsub_file 'README.md', /<node-version>/, node_version

# Download the most recent reports boilerplate
run "curl -o lib/tasks/reports.rake 'https://raw.githubusercontent.com/inigo-llc/ember-cli-rails/master/reports_rake_boilerplate'"
# Download the most recent rubocop boilerplate
run "curl -o .rubocop.yml 'https://raw.githubusercontent.com/inigo-llc/ember-cli-rails/master/rubocop_boilerplate'"

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
run "sed -i.bak '/turbolinks/d' Gemfile"

run "sed -i.bak '/coffee/d' Gemfile"

run "sed -i.bak '/jbuilder/d' Gemfile"
run "sed -i.bak '/jquery-rails/d' Gemfile"
run "sed -i.bak '/Use jquery/d' Gemfile"

run "sed -i.bak '/spring/d' Gemfile"
run "sed -i.bak '/Spring speeds/d' Gemfile"

run "sed -i.bak '/sqlite3/d' Gemfile"

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
# Install development and test gems
gem_group :development, :test do
  gem 'annotate'
  gem 'brakeman'
  gem 'factory_girl_rails'
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
  run 'npm install rails-csrf --save-dev'
  run 'npm install torii --save-dev'
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

# Ember build rake task
rakefile('build.rake') do
  <<-TASK
namespace :ember do
  task :build do
    Dir.chdir('#{ember_app}') do
      sh './node_modules/.bin/ember build --environment=production'
    end

    sh 'mv public/ public.bak/'
    sh 'mkdir public/'
    sh 'cp -r #{ember_app}/dist/ public/'
  end
end
  TASK
end

###
# Recipes
###

# api_me
gem 'api_me'
run 'bundle install'
run 'rails g api_me:install'

# token_authenticate_me
gem 'token_authenticate_me'
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
  run 'npm install ember-authenticate-me --save-dev'
  run 'ember generate user user'
end
prepend_to_file "#{ember_app}/app/router.js" do
  "import AddRoutes from 'ember-authenticate-me/add-routes';\n"
end
inject_into_file 'app-ember/app/router.js', after: "Router.map(function() {" do
  "\n  AddRoutes(this);"
end


# Nyan formatter
gem_group :test do
  gem 'nyan-cat-formatter'
end
run 'bundle install'
append_to_file '.rspec', '--format NyanCatWideFormatter'

puts <<-MESSAGE

***********************************************************

Your ember-cli app is located at: '#{@app_path}/#{ember_app}'
see: https://github.com/stefanpenner/ember-cli

To build the ember project for deployment run

`rake ember:build`

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
