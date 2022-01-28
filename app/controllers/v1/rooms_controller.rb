# frozen_string_literal: true

module V1
  class RoomsController < ApplicationController
    before_action :set_room, only: %i[show update destroy]

    api :GET, '/rooms/:room_id', 'Returns room info'
    error :code => 404,
      :desc => "Not Found - Couldn't find Room with 'id'=<ROOM_ID>"
    error :code => 406,
      :desc => "Not Acceptable - Due the non accepted 'Accept' header"
    formats ['application/vnd.api+json']
    example <<-EOS
      curl "http://localhost:3000/v1/rooms/1" \\
        -H "Accept: application/vnd.api+json"

      # The above command will returns JSON structured like this:
      {
          "data": {
              "id": "1",
              "type": "rooms",
              "attributes": {
                  "name": "Robin DeCraydle"
              }
          }
      }
    EOS
    param :id, Integer, :desc => "Desirable room to search", :required => true
    returns :code => 200, :desc => "a successful response" do
       property :data, Hash, :desc => "A Hash value"
       property :id, Integer, :desc => "Numeric identifier for an Room"
       property :type, String, :desc => "An string value of the record type"
       property :attributes, Hash, :desc => "A Hash with the room info"
       property :name, String, :desc => "The room name"
    end
    def show
      render json: @room
    end

    api :POST, '/rooms', 'Creates a new room'
    error :code => 406,
      :desc => "Not Acceptable - Due the non accepted 'Accept' header"
    error :code => 415,
      :desc => "Unsupported Media Type - Due the non accepted 'Content-type' header"
    error :code => 422,
      :desc => "Unprocessable Entity - The request was well-formed but with fail room validations when tried to create"
    formats ['application/vnd.api+json']
    example <<-EOS
      curl -X POST "http://localhost:3000/v1/rooms" \\
        -H "Accept: application/vnd.api+json" \\
        -H "Content-Type: application/vnd.api+json" \\
        -d '{"data":{"attributes":{"name":"Comum"}}}'

      # The above command will returns JSON structured like this:
      {
          "data": {
              "id": "6",
              "type": "rooms",
              "attributes": {
                  "name": "Comum"
              }
          }
      }
    EOS
    param :name, String, :desc => "The room name", :required => true
    returns :code => 201, :desc => "a successful response" do
      property :data, Hash, :desc => "A Hash value"
      property :id, Integer, :desc => "Numeric identifier for an Room"
      property :type, String, :desc => "An string value of the record type"
      property :attributes, Hash, :desc => "A Hash with the room info"
      property :name, String, :desc => "The room name"
    end
    def create
      @room = Room.new(room_params)

      if @room.save
        render json: @room, status: :created, location: v1_room_url(@room)
      else
        render json: @room.errors, status: :unprocessable_entity
      end
    end

    api :PATCH, '/rooms/:room_id', 'Updates a room'
    error :code => 404,
      :desc => "Not Found - Couldn't find Room with 'id'=<ROOM_ID>"
    error :code => 406,
      :desc => "Not Acceptable - Due the non accepted 'Accept' header"
    error :code => 415,
      :desc => "Unsupported Media Type - Due the non accepted 'Content-type' header"
    error :code => 422,
      :desc => "Unprocessable Entity - The request was well-formed but fail with room validations when tried to create"
    formats ['application/vnd.api+json']
    example <<-EOS
    curl -X PATCH "http://localhost:3000/v1/rooms/1" \\
      -H "Accept: application/vnd.api+json" \\
      -H "Content-Type: application/vnd.api+json" \\
      -d '{"data":{"attributes":{"name":"Especial"}}}'
    ou
    curl -X PUT "http://localhost:3000/v1/rooms/1" \\
      -H "Accept: application/vnd.api+json" \\
      -H "Content-Type: application/vnd.api+json" \\
      -d '{"data":{"attributes":{"name":"Especial"}}}'

      # The above command will returns JSON structured like this:
      {
          "data": {
              "id": "6",
              "type": "rooms",
              "attributes": {
                  "name": "Especial"
              }
          }
      }
    EOS
    param :room_id, Integer, :desc => "Desirable room to update", :required => true
    param :name, String, :desc => "The room name", :required => true
    returns :code => 200, :desc => "a successful response" do
      property :data, Hash, :desc => "A Hash value"
      property :id, Integer, :desc => "Numeric identifier for a Room"
      property :type, String, :desc => "An string value of the record type"
      property :attributes, Hash, :desc => "A Hash with the room info"
      property :name, String, :desc => "The room name"
    end
    def update
      if @room.update(room_params)
        render json: @room
      else
        render json: @room.errors, status: :unprocessable_entity
      end
    end

    api :DELETE, '/rooms/:room_id', 'Deletes a room'
    error :code => 404,
      :desc => "Not Found - Couldn't find Room with 'id'=<ROOM_ID>"
    error :code => 406,
      :desc => "Not Acceptable - Due the non accepted 'Accept' header"
    error :code => 415,
      :desc => "Unsupported Media Type - Due the non accepted 'Content-type' header"
    formats ['application/vnd.api+json']
    example <<-EOS
    curl -X DELETE "http://localhost:3000/v1/rooms/1" \\
      -H "Accept: application/vnd.api+json" \\
      -H "Content-Type: application/vnd.api+json"

      # The above command will returns JSON structured like this:
      nothing
    EOS
    param :room_id, Integer, :desc => "Desirable room to delete", :required => true
    returns :code => 204, :desc => "no content response"
    def destroy
      @room.destroy
    end

    private

    def set_room
      @room = Room.find(params[:id])
    end

    def room_params
      ActiveModelSerializers::Deserialization.jsonapi_parse(params, only: %i[id name])
    end
  end
end
