# frozen_string_literal: true

require './app/validators/appointment_validator'

class Appointment < ApplicationRecord
  belongs_to :user
  belongs_to :room

  validates :title, presence: true, length: { maximum: 50 }
  validates :notes, presence: true, length: { maximum: 140 }
  validates :start_time,
            presence: true,
            comparison: {
              less_than: :end_time,
              message: 'must be less than end_time',
              if: :end_time
            }
  validates :end_time,
            presence: true,
            comparison: {
              greater_than: :start_time,
              message: 'must be greater than start_time',
              if: :start_time
            }

  validate do |appointment|
    AppointmentValidator.new(appointment).validate
  end

  before_create { set_durations_minute }

  paginates_per 5

  private

  def set_durations_minute
    self.start_time = start_time.beginning_of_minute
    self.end_time = end_time.beginning_of_minute
  end
end
