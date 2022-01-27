# frozen_string_literal: true

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

  validate :duration_time_on_weekday,
           :duration_time_in_business_hour,
           :duration_time_same_day,
           :already_took,
           :duration_in_future

  before_create { set_durations_minute }

  paginates_per 5

  private

  def duration_time_on_weekday
    start_time_on_weekday
    end_time_on_weekday
  end

  def start_time_on_weekday
    return if start_time.nil?

    errors.add(:start_time, 'must be on week days') if start_time.on_weekend?
  end

  def end_time_on_weekday
    return if end_time.nil?

    errors.add(:end_time, 'must be on week days') if end_time.on_weekend?
  end

  def duration_time_in_business_hour
    start_time_in_business_hour
    end_time_in_business_hour
  end

  def start_time_in_business_hour
    return if start_time.nil?

    errors.add(:start_time, 'must be during business hours') unless start_time.hour >= 9 && start_time.hour <= 17
  end

  def end_time_in_business_hour
    return if end_time.nil?

    errors.add(:end_time, 'must be during business hours') unless end_time.hour >= 9 && end_time.hour <= 17
  end

  def duration_time_same_day
    return if start_time.nil? || end_time.nil?

    errors.add(:appointment, 'must be on same day') unless start_time.day == end_time.day
  end

  def already_took
    return if start_time.nil? || end_time.nil?

    has_appointments = Appointment.where(
      start_time: start_time.beginning_of_day..start_time.end_of_day
    ).any? { |_a| start_time_took? || end_time_took? }

    errors.add(:appointment, 'already took') if has_appointments
  end

  def start_time_took?
    Appointment.where('? BETWEEN start_time AND end_time AND room_id = ?', start_time, room_id).any?
  end

  def end_time_took?
    Appointment.where('? BETWEEN start_time AND end_time AND room_id = ?', end_time, room_id).any?
  end

  def duration_in_future
    return if start_time.nil? || end_time.nil?

    errors.add(:appointment, 'must be in future date') if start_time < Time.zone.now || end_time < Time.zone.now
  end

  def set_durations_minute
    self.start_time = start_time.beginning_of_minute
    self.end_time = end_time.beginning_of_minute
  end
end
