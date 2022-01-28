# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.3'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails', '~> 7.0', '>= 7.0.1'
# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'
# Use Puma as the app server
gem 'puma', '~> 5.0'
# A library for generating fake data such as names, addresses, and phone numbers.
gem 'faker', '~> 2.19'
# ActiveModel::Serializer implementation and Rails hooks
gem 'active_model_serializers'
# A plugin for versioning Rails based RESTful APIs.
gem 'versionist'
# A sample application showing the power of the Apipie gem
gem 'apipie-rails'
# A Ruby static code analyzer and formatter, based on the community Ruby style guide.
gem 'rubocop', require: false
# A Scope & Engine based, clean, powerful, customizable and sophisticated paginator for Ruby webapps
gem 'kaminari'
# Link header pagination for Rails and Grape APIs.
gem 'api-pagination'
# Repository for collecting Locale data for Ruby on Rails I18n as well as other interesting, Rails related I18n stuff
gem 'rails-i18n'
# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.4', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  # Factory Bot hearts Rails
  gem 'factory_bot_rails'
  # RSpec for Rails 5+
  gem 'rspec-rails'
  # Set of matchers and helpers to allow you test your APIs responses like a pro.
  gem 'rspec-json_expectations'
end

group :development do
  gem 'listen', '~> 3.3'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
