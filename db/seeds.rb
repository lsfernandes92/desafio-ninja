puts "=== Creating some awesome Users..."
10.times do |i|
      User.create!(
        name: Faker::FunnyName.name,
        email: Faker::Internet::email
      )
    end
puts "=== Users successfully created!"
