# frozen_string_literal: true

puts '=== Creating some awesome Users...'
10.times do |_i|
  User.create!(
    name: Faker::FunnyName.name,
    email: Faker::Internet.email
  )
end
puts '=== Users successfully created!'
