# frozen_string_literal: true

module V1
  class RoomsController < ApplicationController
    include ErrorSerializer

    before_action :set_room, only: %i[show update destroy]

    def show
      render json: @room
    end

    def create
      @room = Room.new(room_params)

      if @room.save
        render json: @room, status: :created, location: v1_room_url(@room)
      else
        render json: ErrorSerializer.serialize(@room.errors), status: :unprocessable_entity
      end
    end

    def update
      if @room.update(room_params)
        render json: @room
      else
        render json: ErrorSerializer.serialize(@room.errors), status: :unprocessable_entity
      end
    end

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
