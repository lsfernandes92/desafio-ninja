Apipie.configure do |config|
  config.app_name                = "Desafio ninja"
  config.api_base_url            = "/v1"
  config.doc_base_url            = "/v1/apipie"
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/**/*.rb"
  config.translate = false
  config.app_info["1.0"] = "
    Conference manager app built in Ruby on Rails for GetNinjas job opportunity
  "
end
