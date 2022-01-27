require 'rails_helper'

RSpec.describe Appointment, type: :model do
  subject { build(:appointment) }

  context 'when is being creating' do
    it 'succeds with valid attributes' do
      expect(subject).to be_valid
      expect { subject.save }.to change { Appointment.count }.by(1)
    end
  end

  context 'with validations' do
    it 'validates title presence' do
      subject.title = ''

      expect(subject).not_to be_valid
      expect(subject.errors.full_messages).to match_array(
        ["Title can't be blank"]
      )
    end

    it 'validates title length' do
      subject.title = 'a' * 51

      expect(subject).not_to be_valid
      expect(subject.errors.full_messages).to match_array(
        ['Title is too long (maximum is 50 characters)']
      )
    end

    it 'validates notes presence' do
      subject.notes = ''

      expect(subject).not_to be_valid
      expect(subject.errors.full_messages).to match_array(
        ["Notes can't be blank"]
      )
    end

    it 'validates notes length' do
      subject.notes = 'a' * 141

      expect(subject).not_to be_valid
      expect(subject.errors.full_messages).to match_array(
        ['Notes is too long (maximum is 140 characters)']
      )
    end

    it 'validates start_time presence' do
      subject.start_time = ''

      expect(subject).not_to be_valid
      expect(subject.errors.full_messages).to match_array(
        ["Start time can't be blank", "Start time must be less than end_time"]
      )
    end

    it 'start_time should be less than end_time' do
      travel_to Time.zone.local(2022, 1, 26, 9, 0, 0) do
        subject.start_time = Time.zone.local(2022, 1, 27, 13, 0, 0)
        subject.end_time = Time.zone.local(2022, 1, 27, 12, 0, 0)
      end

      expect(subject).not_to be_valid
      expect(subject.errors.full_messages).to match_array(
        ["End time must be greater than start_time", "Start time must be less than end_time"]
      )
    end

    it 'validates end_time presence' do
      subject.end_time = ''

      expect(subject).not_to be_valid
      expect(subject.errors.full_messages).to match_array(
        ["End time can't be blank", "End time must be greater than start_time"]
      )
    end

    it 'start_time and end_time should be on weekday' do
      travel_to Time.zone.local(2022, 1, 26, 9, 0, 0) do
        subject.start_time = Time.zone.local(2022, 1, 29, 13, 0, 0)
        subject.end_time = Time.zone.local(2022, 1, 29, 14, 0, 0)
      end

      expect(subject).not_to be_valid
      expect(subject.errors.full_messages).to match_array(
        ["End time must be on week days", "Start time must be on week days"]
      )
    end

    it 'start_time should be in business hour' do
      travel_to Time.zone.local(2022, 1, 26, 9, 0, 0) do
        subject.start_time = Time.zone.local(2022, 1, 27, 8, 0, 0)
        subject.end_time = Time.zone.local(2022, 1, 27, 14, 0, 0)
      end

      expect(subject).not_to be_valid
      expect(subject.errors.full_messages).to match_array(
        ["Start time must be during business hours"]
      )
    end

    it 'end_time should be in business hour' do
      travel_to Time.zone.local(2022, 1, 26, 9, 0, 0) do
        subject.start_time = Time.zone.local(2022, 1, 27, 17, 0, 0)
        subject.end_time = Time.zone.local(2022, 1, 27, 18, 1, 0)
      end

      expect(subject).not_to be_valid
      expect(subject.errors.full_messages).to match_array(
        ["End time must be during business hours"]
      )
    end

    it 'start_time and end_time should be on same day' do
      travel_to Time.zone.local(2022, 1, 26, 9, 0, 0) do
        subject.start_time = Time.zone.local(2022, 1, 27, 17, 0, 0)
        subject.end_time = Time.zone.local(2022, 1, 28, 17, 1, 0)
      end

      expect(subject).not_to be_valid
      expect(subject.errors.full_messages).to match_array(
        ["Appointment must be on same day"]
      )
    end

    it 'validates if appointment time already took' do
      travel_to Time.zone.local(2022, 1, 26, 8, 0, 0) do
        create(:appointment)
        subject.start_time = Time.zone.local(2022, 12, 26, 9, 0, 0)
        subject.end_time = Time.zone.local(2022, 12, 26, 17, 0, 0)
      end

      expect(subject).not_to be_valid
      expect(subject.errors.full_messages).to match_array(
        ["Appointment already took"]
      )
    end

    it 'appointment should be on future date and time' do
      travel_to Time.zone.local(2022, 1, 26, 9, 0, 0) do
        subject.start_time = Time.zone.local(2022, 1, 25, 17, 0, 0)
        subject.end_time = Time.zone.local(2022, 1, 25, 17, 1, 0)
      end

      expect(subject).not_to be_valid
      expect(subject.errors.full_messages).to match_array(
        ["Appointment must be in future date"]
      )
    end
  end
end
