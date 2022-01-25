# frozen_string_literal: true

puts '=== Creating some awesome Users...'
10.times do |_i|
  User.create!(
    name: Faker::FunnyName.name,
    email: Faker::Internet.email
  )
end
puts '=== Users successfully created!'

puts '=== Creating some Appointments...'
5.times do |_i|
  Appointment.create!(
    title: Faker::Lorem.sentence(word_count: 3),
    notes: Faker::Lorem.sentence(word_count: 5),
    start_time: Faker::Time.forward(days: 1, period: :morning),
    end_time: Faker::Time.forward(days: 1, period: :evening),
    user: User.all.sample
  )
end
puts '=== Appointments successfully created!'
