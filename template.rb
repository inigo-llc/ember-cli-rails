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

action_messages = []

# Install required gems
gem 'api_me'
gem 'pg'
gem 'squeel'

# Install production gems
gem_group :production do
  gem 'rails_12factor'
end

# Install development and test gems
gem_group :development, :test do
  gem 'annotate'
  gem 'brakeman'
  gem 'factory_girl_rails'
  gem 'rspec-rails'
  gem 'rubocop'
end

# kill un-needed gems
run "sed -i.bak '/turbolinks/d' Gemfile"
run "sed -i.bak '/coffee/d' Gemfile"
run "sed -i.bak '/jbuilder/d' Gemfile"
run "sed -i.bak '/jquery-rails/d' Gemfile"
run "sed -i.bak '/sqlite3/d' Gemfile"
run "sed -i.bak '/sass-rails/d' Gemfile"
run "sed -i.bak '/uglifier/d' Gemfile"

# Keep before bundle install
create_file '.ruby-version' do
  '2.1.4'
end

# Install gems using bundler
run 'bundle install'

# cleanup
run 'rm Gemfile.bak'

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

# Download the most recent gitignore file
run "curl -o .gitignore 'https://raw.githubusercontent.com/inigo-llc/ember-cli-rails/master/gitignore_template'"

create_file '.nvmrc' do
  '0.10.32'
end

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

route "get :csrf, to: 'csrf#index'"
inject_into_file 'config/routes.rb',
                 before: '  # Clobbers all routes, Keep this as the last route in the routes file' do
  "\n\n"
end

file 'app/controllers/api/csrf_controller.rb', <<-FILE
class Api::CsrfController < ApplicationController
def index
  render json: { request_forgery_protection_token => form_authenticity_token }.to_json
end
end
FILE

inside "#{ember_app}" do
  run 'npm install rails-csrf --save-dev'
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

# Initialize git repo
run 'git init'

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
