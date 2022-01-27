# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    name { Faker::FunnyName.name }
    email { Faker::Internet.email }

    trait :invalid do
      name { '' }
      email { '' }
    end

    factory :invalid_user, traits: [:invalid]

    trait :with_appointments do
      after(:create) do |user, evaluator|
        create_list(
          :appointment,
          evaluator.appointments_quantity,
          user: user
        )
      end
    end

    factory :user_with_appointments, traits: [:with_appointments]
  end
end
