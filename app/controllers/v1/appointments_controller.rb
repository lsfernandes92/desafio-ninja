module V1
  class AppointmentsController < ApplicationController
    before_action :set_user

    def show
      render json: @user.appointments
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

    def update
      appointment = Appointment.find(appointment_params[:id])

      if appointment.update(appointment_params)
        render json: @user.appointments
      else
        render json: appointment.errors, status: :unprocessable_entity
      end
    end

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
        only: %i[id title notes start_time end_time]
      )
    end
  end
end
