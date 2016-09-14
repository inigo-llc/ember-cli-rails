require 'factory_girl'
require 'faker'

namespace :demo do
  task seed: :environment do
    ActiveRecord::Base.transaction do
      #
    end
  end
end
