Rails.application.routes.draw do
  apipie
  api_version(:module => "V1", :path => {:value => "v1"}) do
    resources :users
  end
end
