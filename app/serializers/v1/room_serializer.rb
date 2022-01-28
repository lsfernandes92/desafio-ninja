# frozen_string_literal: true

module V1
  class RoomSerializer < ActiveModel::Serializer
    attributes :id, :name

    has_many :appointments do
      link(:related) { v1_room_appointments_url(object.id) }
    end

    link(:self) { v1_room_url(object) }
  end
end
