# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Room, type: :model do
  subject { build(:room) }

  context 'when is being creating' do
    it 'succeds with valid attributes' do
      expect(subject).to be_valid
      expect { subject.save }.to change { Room.count }.by(1)
    end
  end

  context 'with validations' do
    it 'validates name presence' do
      subject.name = ''

      expect(subject).not_to be_valid
      expect(subject.errors.full_messages).to match_array(
        ["Name can't be blank"]
      )
    end

    it 'validates name length' do
      subject.name = 'a' * 51

      expect(subject).not_to be_valid
      expect(subject.errors.full_messages).to match_array(
        ['Name is too long (maximum is 50 characters)']
      )
    end
  end
end
