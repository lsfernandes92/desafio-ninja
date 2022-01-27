# frozen_string_literal: true

FactoryBot.define do
  factory :appointment do
    title { Faker::Lorem.sentence(word_count: 3) }
    notes { Faker::Lorem.sentence(word_count: 5) }
    start_time { Time.zone.local(2022, 12, 26, 9, 0, 0) }
    end_time { Time.zone.local(2022, 12, 26, 12, 0, 0) }
    association :user, factory: :user
    association :room, factory: :room
  end
end
