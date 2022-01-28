# frozen_string_literal: true

module V1
  class UserSerializer < ActiveModel::Serializer
    attributes :id, :name, :email

    has_many :appointments do
      link(:related) { v1_user_appointments_url(object.id) }
    end

    link(:self) { v1_user_url(object) }
  end
end
