class Appointment < ApplicationRecord
  belongs_to :user

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

  private

    def duration_time_on_weekday
      start_time_on_weekday
      end_time_on_weekday
    end

    def start_time_on_weekday
      return if start_time.nil?
      if start_time.on_weekend?
        errors.add(:start_time, 'must be on week days')
      end
    end

    def end_time_on_weekday
      return if end_time.nil?
      if end_time.on_weekend?
        errors.add(:end_time, 'must be on week days')
      end
    end

    def duration_time_in_business_hour
      start_time_in_business_hour
      end_time_in_business_hour
    end

    def start_time_in_business_hour
      return if start_time.nil?
      unless (start_time.hour >= 9 && start_time.hour <= 17)
        errors.add(:start_time, 'must be during business hours')
      end
    end

    def end_time_in_business_hour
      return if end_time.nil?
      unless (end_time.hour >= 9 && end_time.hour <= 17)
        errors.add(:end_time, 'must be during business hours')
      end
    end

    def duration_time_same_day
      return if start_time.nil? || end_time.nil?
      unless (start_time.day == end_time.day)
        errors.add(:appointment, 'must be on same day')
      end
    end

    def already_took
      return if start_time.nil? || end_time.nil?
      has_appointments = Appointment.where(
        start_time: self.start_time.beginning_of_day..self.start_time.end_of_day
      ).any?{ |a| start_time_took?(a) || end_time_took?(a) }

      if has_appointments
        errors.add(:appointment, 'already took')
      end
    end

    def start_time_took?(appointment)
      Appointment.where("? BETWEEN start_time AND end_time", self.start_time).any?
    end

    def end_time_took?(appointment)
      Appointment.where("? BETWEEN start_time AND end_time", self.end_time).any?
    end

    def duration_in_future
      return if start_time.nil? || end_time.nil?
      if (start_time < Time.zone.now || end_time < Time.zone.now)
        errors.add(:appointment, 'must be in future date')
      end
    end

    def set_durations_minute
      self.start_time = start_time.beginning_of_minute
      self.end_time = end_time.beginning_of_minute
    end
end
