# frozen_string_literal: true

module V1
  class AppointmentsController < ApplicationController
    before_action :set_user

    api :GET, '/users/:user_id/relationships/appointments', 'Returns all user appointments'
    error :code => 406,
      :desc => "Not Acceptable - Due the non accepted 'Accept' header"
    error :code => 404,
      :desc => "Not Found - Couldn't find User with 'id'=<USER_ID>"
    formats ['application/vnd.api+json']
    example <<-EOS
      curl "http://localhost:3000/v1/users/1/relationships/appointments" \\
        -H "Accept: application/vnd.api+json"

      # The above command will returns JSON structured like this:
      {
          "data": [
              {
                  "id": "1",
                  "type": "appointments",
                  "attributes": {
                      "title": "Voluptatum explicabo excepturi.",
                      "notes": "Dolorem aperiam laboriosam odit quia.",
                      "start-time": "27/12/2022  9:00",
                      "end-time": "27/12/2022 18:00"
                  },
                  "relationships": {
                      "user": {
                          "data": {
                              "id": "1",
                              "type": "users"
                          }
                      },
                      "room": {
                          "data": {
                              "id": "3",
                              "type": "rooms"
                          }
                      }
                  }
              },
              ...
              ...
              ...
          ]
      }
    EOS
    returns :code => 200, :desc => "a successful response" do
       property :data, Hash, :desc => "An Array of Hashes"
       property :id, Integer, :desc => "Numeric identifier for an Appointment"
       property :type, String, :desc => "An string value of the record type"
       property :attributes, Hash, :desc => "A Hash with the appointment info"
       property :title, String, :desc => "The appointment title"
       property :notes, String, :desc => "The appointment notes"
       property :start_time, String, :desc => "The appointment start_time"
       property :end_time, String, :desc => "The appointment end_time"
       property :relationships, Hash, :desc => "Hash with the appointment relationships"
    end
    api :GET, '/rooms/:room_id/relationships/appointments', 'Returns all room appointments'
    error :code => 406,
      :desc => "Not Acceptable - Due the non accepted 'Accept' header"
    error :code => 404,
      :desc => "Not Found - Couldn't find Room with 'id'=<ROOM_ID>"
    formats ['application/vnd.api+json']
    example <<-EOS
      curl "http://localhost:3000/v1/rooms/1/relationships/appointments" \\
        -H "Accept: application/vnd.api+json"

      # The above command will returns JSON structured like this:
      {
          "data": [
              {
                  "id": "1",
                  "type": "appointments",
                  "attributes": {
                      "title": "Voluptatum explicabo excepturi.",
                      "notes": "Dolorem aperiam laboriosam odit quia.",
                      "start-time": "27/12/2022  9:00",
                      "end-time": "27/12/2022 18:00"
                  },
                  "relationships": {
                      "user": {
                          "data": {
                              "id": "1",
                              "type": "users"
                          }
                      },
                      "room": {
                          "data": {
                              "id": "1",
                              "type": "rooms"
                          }
                      }
                  }
              },
              ...
              ...
              ...
          ]
      }
    EOS
    returns :code => 200, :desc => "a successful response" do
       property :data, Hash, :desc => "An Array of Hashes"
       property :id, Integer, :desc => "Numeric identifier for an Appointment"
       property :type, String, :desc => "An string value of the record type"
       property :attributes, Hash, :desc => "A Hash with the appointment info"
       property :title, String, :desc => "The appointment title"
       property :notes, String, :desc => "The appointment notes"
       property :start_time, String, :desc => "The appointment start_time"
       property :end_time, String, :desc => "The appointment end_time"
       property :relationships, Hash, :desc => "Hash with the appointment relationships"
    end
    def show
      page_number = params[:page].try(:[], :number)
      per_page = params[:page].try(:[], :size)
      appointments = @user.appointments.all.page(page_number).per(per_page)

      render json: appointments
    end

    api :POST, '/users/:user_id/relationships/appointment', 'Creates a new appointment for the given user'
    error :code => 406,
      :desc => "Not Acceptable - Due the non accepted 'Accept' header"
    error :code => 415,
      :desc => "Unsupported Media Type - Due the non accepted 'Content-type' header"
    error :code => 422,
      :desc => "Unprocessable Entity - The request was well-formed but with fail appointment validations when tried to create"
    error :code => 404,
      :desc => "Not Found - Couldn't find User with 'id'=<USER_ID>"
    formats ['application/vnd.api+json']
    example <<-EOS
      curl -X POST "http://localhost:3000/v1/users/1/relationships/appointment" \\
        -H "Accept: application/vnd.api+json" \\
        -H "Content-Type: application/vnd.api+json" \\
        -d '{"data":{"type":"appointments","attributes":{"title":"Reunião onboarding Lucas","notes":"Passagem de conhecimento dos fluxos","start_time":"26/12/2022 10:00","end_time":"26/12/2022 11:00","room_id":"2"}}}'

      # The above command will returns JSON structured like this:
      {
          "data": [
              {
                  "id": "2",
                  "type": "appointments",
                  "attributes": {
                      "title": "Reunião onboarding Lucas",
                      "notes": "Passagem de conhecimento dos fluxos",
                      "start-time": "26/01/2022 10:00",
                      "end-time": "25/01/2022 11:00"
                  },
                  "relationships": {
                      "user": {
                          "data": {
                              "id": "1",
                              "type": "users"
                          }
                      },
                      "room": {
                          "data": {
                              "id": "2",
                              "type": "rooms"
                          }
                      }
                  }
              },
              ...
              ...
              ...
          ]
      }
    EOS
    param :user_id, Integer, :desc => "Numeric identifier for a User who will possess the new appointment", :required => true
    param :title, String, :desc => "The appointment title", :required => true
    param :notes, String, :desc => "The appointment notes", :required => true
    param :start_time, String, :desc => "The appointment start_time", :required => true
    param :end_time, String, :desc => "The appointment end_time", :required => true
    returns :code => 201, :desc => "a successful response" do
      property :data, Hash, :desc => "A Hash value"
      property :id, Integer, :desc => "Numeric identifier for an Appointment"
      property :type, String, :desc => "An string value of the record type"
      property :attributes, Hash, :desc => "A Hash with the user appointments infos"
      property :title, String, :desc => "The appointment title"
      property :notes, String, :desc => "The appointment notes"
      property :start_time, String, :desc => "The appointment start_time"
      property :end_time, String, :desc => "The appointment end_time"
      property :relationships, Hash, :desc => "Hash with the appointment relationships"
    end
    def create
      appointment = Appointment.new(appointment_params)
      @user.appointments << appointment

      if @user.save
        render json: @user.appointments, status: :created, location: v1_user_appointments_path(@user)
      else
        render json: appointment.errors, status: :unprocessable_entity
      end
    end

    api :PATCH, '/users/:user_id/relationships/appointment', 'Updates an user appointment'
    error :code => 404,
      :desc => "Not Found - Couldn't find User with 'id'=<USER_ID>"
    error :code => 406,
      :desc => "Not Acceptable - Due the non accepted 'Accept' header"
    error :code => 415,
      :desc => "Unsupported Media Type - Due the non accepted 'Content-type' header"
    error :code => 422,
      :desc => "Unprocessable Entity - The request was well-formed but fail with appointment validations when tried to create"
    formats ['application/vnd.api+json']
    example <<-EOS
    curl -X PATCH "http://localhost:3000/v1/users/1/relationships/appointment" \\
      -H "Accept: application/vnd.api+json" \\
      -H "Content-Type: application/vnd.api+json" \\
      -d '{"data":{"id": "3","type":"appointments","attributes":{"title":"Team build","notes":"Café, gincanas e alegria","start_time":"27/12/2022 10:00","end_time":"27/12/2022 11:00","room_id":"2"}}}'
    ou
    curl -X PUT "http://localhost:3000/v1/users/1/relationships/appointment" \\
      -H "Accept: application/vnd.api+json" \\
      -H "Content-Type: application/vnd.api+json" \\
      -d '{"data":{"id": "3","type":"appointments","attributes":{"title":"Team build","notes":"Café, gincanas e alegria","start_time":"27/12/2022 10:00","end_time":"27/12/2022 11:00","room_id":"2"}}}'

      # The above command will returns JSON structured like this:
      {
          "data": [
              {
                  "id": "3",
                  "type": "appointments",
                  "attributes": {
                      "title": "Team build",
                      "notes": "Café, gincanas e alegria",
                      "start-time": "26/01/2022 10:00",
                      "end-time": "25/01/2022 11:00"
                  },
                  "relationships": {
                      "user": {
                          "data": {
                              "id": "1",
                              "type": "users"
                          }
                      },
                      "room": {
                          "data": {
                              "id": "2",
                              "type": "rooms"
                          }
                      }
                  }
              },
              ...
              ...
              ...
          ]
      }
    EOS
    param :user_id, Integer, :desc => "Numeric identifier for a User who will possess the new appointment", :required => true
    param :title, String, :desc => "The appointment title", :required => true
    param :notes, String, :desc => "The appointment notes", :required => true
    param :start_time, String, :desc => "The appointment start_time", :required => true
    param :end_time, String, :desc => "The appointment end_time", :required => true
    returns :code => 200, :desc => "a successful response" do
      property :data, Hash, :desc => "A Hash value"
      property :id, Integer, :desc => "Numeric identifier for an Appointment"
      property :type, String, :desc => "An string value of the record type"
      property :attributes, Hash, :desc => "A Hash with the user appointments infos"
      property :title, String, :desc => "The appointment title"
      property :notes, String, :desc => "The appointment notes"
      property :start_time, String, :desc => "The appointment start_time"
      property :end_time, String, :desc => "The appointment end_time"
      property :relationships, Hash, :desc => "Hash with the appointment relationships"
    end
    def update
      appointment = Appointment.find(appointment_params[:id])

      if appointment.update(appointment_params)
        render json: @user.appointments
      else
        render json: appointment.errors, status: :unprocessable_entity
      end
    end

    api :DELETE, 'users/:user_id/relationships/appointment', 'Deletes an user appointment'
    error :code => 404,
      :desc => "Not Found - Couldn't find User with 'id'=<USER_ID>"
    error :code => 406,
      :desc => "Not Acceptable - Due the non accepted 'Accept' header"
    error :code => 415,
      :desc => "Unsupported Media Type - Due the non accepted 'Content-type' header"
    formats ['application/vnd.api+json']
    example <<-EOS
    curl -X DELETE "http://localhost:3000/v1/users/1/relationships/appointment" \\
      -H "Accept: application/vnd.api+json" \\
      -H "Content-Type: application/vnd.api+json" \\
      -d '{"data":{"id":"10"}}'

      # The above command will returns JSON structured like this:
      nothing
    EOS
    param :user_id, Integer, :desc => "Numeric identifier for a User who the appointment will be deleted", :required => true
    param :appointment_id, Integer, :desc => "Numeric identifier for one Appointment", :required => true
    returns :code => 204, :desc => "no content response"
    def destroy
      Appointment.find(appointment_params[:id]).destroy
    end

    private

    def set_user
      @user = User.find(params[:user_id])
    end

    def appointment_params
      ActiveModelSerializers::Deserialization.jsonapi_parse(
        params,
        only: %i[id title notes start_time end_time room_id]
      )
    end
  end
end
