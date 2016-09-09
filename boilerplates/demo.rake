require 'factory_girl'
require 'faker'

namespace :demo do
  task seed: :environment do
    ActiveRecord::Base.transaction do
      user = FactoryGirl.create(:user,
        username: 'admin',
        password: 'Password',
        password_confirmation: 'Password'
      )
    end
  end
end
