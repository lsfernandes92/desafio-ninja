# frozen_string_literal: true

class Room < ApplicationRecord
  has_many :appointments

  validates :name, presence: true, length: { maximum: 50 }
end
