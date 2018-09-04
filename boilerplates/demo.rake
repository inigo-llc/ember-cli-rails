require 'factory_bot_rails'
require 'faker'

namespace :demo do
  task seed: :environment do
    ActiveRecord::Base.transaction do
      user = TokenAuthenticateMe::User.new(username: 'admin', password: 'Password', email: 'admin@wild.land')
      user.save!(validate: false)
    end
  end
end
