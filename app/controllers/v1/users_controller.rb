# frozen_string_literal: true

module V1
  class UsersController < ApplicationController
    include ErrorSerializer

    before_action :set_user, only: %i[show update destroy]

    def index
      page_number = params[:page].try(:[], :number)
      per_page = params[:page].try(:[], :size)
      @users = User.all.page(page_number).per(per_page)

      render json: @users
    end

    def show
      render json: @user
    end

    def create
      @user = User.new(user_params)

      if @user.save
        render json: @user, status: :created, location: v1_user_url(@user)
      else
        render json: ErrorSerializer.serialize(@user.errors), status: :unprocessable_entity
      end
    end

    def update
      if @user.update(user_params)
        render json: @user
      else
        render json: ErrorSerializer.serialize(@user.errors), status: :unprocessable_entity
      end
    end

    def destroy
      @user.destroy
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      ActiveModelSerializers::Deserialization.jsonapi_parse(
        params,
        only: %i[id name email]
      )
    end
  end
end
