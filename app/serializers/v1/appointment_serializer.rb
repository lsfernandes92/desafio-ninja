module V1
  class AppointmentSerializer < ActiveModel::Serializer
    attributes :id, :title, :notes, :start_time, :end_time

    belongs_to :user
  end
end
