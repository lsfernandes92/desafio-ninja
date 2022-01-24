# frozen_string_literal: true

namespace :dev do
  desc 'Config development environment'
  task setup: :environment do
    puts '=== Reseting data base with seed than run migrate'
    `bin/rails db:drop db:create db:migrate db:seed`
    puts '=== Data base reset finished!'
  end
end
