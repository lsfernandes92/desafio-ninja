require 'rails_helper'

RSpec.describe User, type: :model do
  subject { build(:user) }

  context 'when is being creating' do
    it 'succeds with valid attributes' do
      expect(subject).to be_valid
      expect{ subject.save }.to change{ User.count }.by(1)
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
      subject.name = "a" * 51

      expect(subject).not_to be_valid
      expect(subject.errors.full_messages).to match_array(
        ["Name is too long (maximum is 50 characters)"]
      )
    end

    it 'validates email presence' do
      subject.email = ''

      expect(subject).not_to be_valid
      expect(subject.errors.full_messages).to match_array(
        ["Email can't be blank", "Email is invalid"]
      )
    end

    it 'validates email length' do
      subject.email = "a" * 255 + '@gmail.com'

      expect(subject).not_to be_valid
      expect(subject.errors.full_messages).to match_array(
        ["Email is too long (maximum is 255 characters)"]
      )
    end

    it 'validates email format' do
      subject.email = 'agmail.com'

      expect(subject).not_to be_valid
      expect(subject.errors.full_messages).to match_array(
        ["Email is invalid"]
      )
    end

    it 'validates email uniqueness' do
      dup_user = subject.dup
      subject.save
      expect(dup_user).not_to be_valid
    end
  end
end
