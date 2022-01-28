# frozen_string_literal: true

module V1
  class AppointmentsController < ApplicationController
    include ErrorSerializer

    before_action :set_user, only: %i[create update destroy]
    before_action :set_resource, only: :show

    def show
      page_number = params[:page].try(:[], :number)
      per_page = params[:page].try(:[], :size)

      appointments = @resource.appointments.all.page(page_number).per(per_page)

      render json: appointments
    end

    def create
      appointment = Appointment.new(appointment_params)
      @user.appointments << appointment

      if @user.save
        render json: @user.appointments, status: :created, location: v1_user_appointments_path(@user)
      else
        render json: ErrorSerializer.serialize(appointment.errors), status: :unprocessable_entity
      end
    end

    def update
      appointment = Appointment.find(appointment_params[:id])

      if appointment.update(appointment_params.merge(user_id: params[:user_id]))
        render json: @user.appointments
      else
        render json: ErrorSerializer.serialize(appointment.errors), status: :unprocessable_entity
      end
    end

    def destroy
      Appointment.find(appointment_params[:id]).destroy
    end

    private

    def set_user
      @user = User.find(params[:user_id])
    end

    def set_resource
      @resource =
        if params[:room_id].present?
          Room.find(params[:room_id])
        else
          User.find(params[:user_id])
        end
    end

    def appointment_params
      ActiveModelSerializers::Deserialization.jsonapi_parse(
        params,
        only: %i[id title notes start_time end_time room_id]
      )
    end
  end
end
