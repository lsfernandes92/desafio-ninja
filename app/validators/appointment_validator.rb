# frozen_string_literal: true

class AppointmentValidator
  def initialize(appointment)
    @appointment = appointment
  end

  def validate
    duration_time_on_weekday
    duration_time_in_business_hour
    duration_time_same_day
    already_took
    duration_in_future
  end

  private

  def duration_time_on_weekday
    start_time_on_weekday
    end_time_on_weekday
  end

  def start_time_on_weekday
    return if @appointment.start_time.nil?

    @appointment.errors.add(:start_time, 'must be on week days') if @appointment.start_time.on_weekend?
  end

  def end_time_on_weekday
    return if @appointment.end_time.nil?

    @appointment.errors.add(:end_time, 'must be on week days') if @appointment.end_time.on_weekend?
  end

  def duration_time_in_business_hour
    start_time_in_business_hour
    end_time_in_business_hour
  end

  def start_time_in_business_hour
    return if @appointment.start_time.nil?

    unless @appointment.start_time.hour >= 9 && @appointment.start_time.hour <= 17
      @appointment.errors.add(:start_time, 'must be during business hours')
    end
  end

  def end_time_in_business_hour
    return if @appointment.end_time.nil?

    unless @appointment.end_time.hour >= 9 && @appointment.end_time.hour <= 17
      @appointment.errors.add(:end_time, 'must be during business hours')
    end
  end

  def duration_time_same_day
    return if @appointment.start_time.nil? || @appointment.end_time.nil?

    unless @appointment.start_time.day == @appointment.end_time.day
      @appointment.errors.add(:appointment, 'must be on same day')
    end
  end

  def already_took
    return if @appointment.start_time.nil? || @appointment.end_time.nil?

    has_appointments = Appointment.where(
      start_time: @appointment.start_time.beginning_of_day..@appointment.start_time.end_of_day
    ).any? { |_a| start_time_took? || end_time_took? }

    @appointment.errors.add(:appointment, 'already took') if has_appointments
  end

  def start_time_took?
    Appointment.where(
      '? BETWEEN start_time AND end_time AND room_id = ?',
      @appointment.start_time,
      @appointment.room_id
    ).any?
  end

  def end_time_took?
    Appointment.where(
      '? BETWEEN start_time AND end_time AND room_id = ?',
      @appointment.end_time,
      @appointment.room_id
    ).any?
  end

  def duration_in_future
    return if @appointment.start_time.nil? || @appointment.end_time.nil?

    if @appointment.start_time < Time.zone.now || @appointment.end_time < Time.zone.now
      @appointment.errors.add(:appointment, 'must be in future date')
    end
  end
end
