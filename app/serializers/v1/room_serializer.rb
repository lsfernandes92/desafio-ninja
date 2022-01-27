# frozen_string_literal: true

module V1
  class RoomSerializer < ActiveModel::Serializer
    attributes :id, :name
  end
end
