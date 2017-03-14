module TokenAuthenticateMe
  class SessionSerializer < ActiveModel::Serializer
    attributes :key, :expiration, :created_at, :updated_at

    has_one :user
  end
end
