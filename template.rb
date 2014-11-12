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
run "sed -i.bck '/turbolinks/d' Gemfile"
run "sed -i.bck '/coffee/d' Gemfile"
run "sed -i.bck '/jbuilder/d' Gemfile"
run "sed -i.bck '/jquery-rails/d' Gemfile"
run "sed -i.bck '/sqlite3/d' Gemfile"
run "sed -i.bck '/sass-rails/d' Gemfile"
run "sed -i.bck '/uglifier/d' Gemfile"

# Install gems using bundler
run "bundle install"

# cleanup
run "rm Gemfile.bck"

ember_app = "#{@app_name}-ember"

# create ember-cli app
run "ember new #{ember_app}"

inject_into_class "app/controllers/ember_application_controller.rb" do
<<-FILE
class EmberApplicationController < ApplicationController
  def index
    render file: 'public/index.html'
  end
end
FILE
end

puts <<-MESSAGE

***********************************************************

Your ember-cli app is located at: '#{@app_path}/#{ember_app}'
see: https://github.com/stefanpenner/ember-cli

To build the ember project for deployment run

`./bin/build.sh`

***********************************************************

MESSAGE
