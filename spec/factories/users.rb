# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    name { Faker::FunnyName.name }
    email { Faker::Internet.email }

    trait :invalid do
      name { '' }
      email { '' }
    end

    transient do
      appointments_quantity { 1 }
    end

    factory :invalid_user, traits: [:invalid]

    trait :with_appointment do
      after(:create) do |user, evaluator|
        create_list(
          :appointment,
          evaluator.appointments_quantity,
          user: user
        )
      end
    end

    factory :user_with_appointment, traits: [:with_appointment]
  end
end
