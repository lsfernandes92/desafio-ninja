# frozen_string_literal: true

FactoryBot.define do
  factory :room do
    name { Faker::FunnyName.name }

    transient do
      appointments_quantity { 1 }
    end

    trait :with_appointment do
      after(:create) do |room, evaluator|
        create_list(
          :appointment,
          evaluator.appointments_quantity,
          room: room
        )
      end
    end

    factory :room_with_appointment, traits: [:with_appointment]
  end
end
