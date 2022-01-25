# frozen_string_literal: true

module V1
  class UserSerializer < ActiveModel::Serializer
    attributes :id, :name, :email

    has_many :appointments
  end
end
