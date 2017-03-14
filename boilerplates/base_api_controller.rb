require 'token_authenticate_me/concerns/controllers/token_authenticateable'

module Api
  module V1
    class BaseController < ApplicationController
      include ActionController::HttpAuthentication::Token::ControllerMethods
      include TokenAuthenticateMe::Concerns::Controllers::TokenAuthenticateable

      skip_before_action :verify_authenticity_token

      force_ssl if Rails.env.production?
    end
  end
end
