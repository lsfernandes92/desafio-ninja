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
Appointment.create!(
  title: Faker::Lorem.sentence(word_count: 3),
  notes: Faker::Lorem.sentence(word_count: 5),
  start_time: Time.zone.local(2022, 12, 26, 9, 0, 0),
  end_time: Time.zone.local(2022, 12, 26, 18, 0, 0),
  user: User.all.sample
)
Appointment.create!(
  title: Faker::Lorem.sentence(word_count: 3),
  notes: Faker::Lorem.sentence(word_count: 5),
  start_time: Time.zone.local(2022, 12, 27, 9, 0, 0),
  end_time: Time.zone.local(2022, 12, 27, 18, 0, 0),
  user: User.all.sample
)
Appointment.create!(
  title: Faker::Lorem.sentence(word_count: 3),
  notes: Faker::Lorem.sentence(word_count: 5),
  start_time: Time.zone.local(2022, 12, 29, 9, 0, 0),
  end_time: Time.zone.local(2022, 12, 29, 12, 0, 0),
  user: User.all.sample
)
Appointment.create!(
  title: Faker::Lorem.sentence(word_count: 3),
  notes: Faker::Lorem.sentence(word_count: 5),
  start_time: Time.zone.local(2022, 12, 29, 12, 1, 0),
  end_time: Time.zone.local(2022, 12, 29, 13, 0, 0),
  user: User.all.sample
)
Appointment.create!(
  title: Faker::Lorem.sentence(word_count: 3),
  notes: Faker::Lorem.sentence(word_count: 5),
  start_time: Time.zone.local(2022, 12, 29, 17, 1, 0),
  end_time: Time.zone.local(2022, 12, 29, 18, 0, 0),
  user: User.all.sample
)
puts '=== Appointments successfully created!'
