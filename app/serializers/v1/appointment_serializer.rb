# frozen_string_literal: true

module V1
  class AppointmentSerializer < ActiveModel::Serializer
    attributes :id, :title, :notes, :start_time, :end_time

    belongs_to :user do
      link(:related) { v1_user_url(object.user_id) }
    end

    belongs_to :room do
      link(:related) { v1_room_url(object.room_id) }
    end

    link(:self) { v1_user_appointments_url(object.user_id) }

    def attributes(*args)
      h = super(*args)
      h[:start_time] = (I18n.l(object.start_time) unless object.start_time.blank?)
      h[:end_time] = (I18n.l(object.end_time) unless object.end_time.blank?)
      h
    end
  end
end
