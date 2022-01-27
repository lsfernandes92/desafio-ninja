# frozen_string_literal: true

Rails.application.routes.draw do
  api_version(module: 'V1', path: { value: 'v1' }) do
    resources :users do
      resource :appointments, only: [:show], path: 'relationships/appointments'
      resource :appointment, only: %i[update create destroy], path: 'relationships/appointment'
    end

    resources :rooms do
      resource :appointments, only: [:show], path: 'relationships/appointments'
    end
  end
end
