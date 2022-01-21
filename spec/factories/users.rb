FactoryBot.define do
  factory :user do
    name { Faker::FunnyName.name }
    email { Faker::Internet.email }

    trait :invalid do
      name { '' }
      email { '' }
    end

    factory :invalid_user, traits: [:invalid]
  end
end
