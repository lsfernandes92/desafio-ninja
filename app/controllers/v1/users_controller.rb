# frozen_string_literal: true

module V1
  class UsersController < ApplicationController
    before_action :set_user, only: %i[show update destroy]

    api :GET, '/users', 'Returns all users'
    error :code => 406,
      :desc => "Not Acceptable - Due the non accepted 'Accept' header"
    formats ['application/vnd.api+json']
    example <<-EOS
      curl "http://localhost:3000/v1/users/" \\
        -H "Accept: application/vnd.api+json" \\

      # The above command will returns JSON structured like this:
      {
          "data": [
              {
                  "id": "1",
                  "type": "users",
                  "attributes": {
                      "name": "I. P. Freely",
                      "email": "mathilde@kerluke-buckridge.com"
                  },
                  "relationships": {
                      "appointments": {
                          "data": [
                              {
                                  "id": "2",
                                  "type": "appointments"
                              },
                              ...
                              ...
                              ...
                          ]
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
       property :id, Integer, :desc => "Numeric identifier for an User"
       property :type, String, :desc => "An string value of the record type"
       property :attributes, Hash, :desc => "A Hash with the user info"
       property :name, String, :desc => "The user name"
       property :email, String, :desc => "The user email"
       property :relationships, Hash, :desc => "Hash with the user relationships"
    end
    def index
      page_number = params[:page].try(:[], :number)
      per_page = params[:page].try(:[], :size)
      @users = User.all.page(page_number).per(per_page)

      render json: @users
    end

    api :GET, '/users/:id', 'Returns user info'
    error :code => 404,
      :desc => "Not Found - Couldn't find User with 'id'=<USER_ID>"
    error :code => 406,
      :desc => "Not Acceptable - Due the non accepted 'Accept' header"
    formats ['application/vnd.api+json']
    example <<-EOS
      curl "http://localhost:3000/v1/users/1" \\
        -H "Accept: application/vnd.api+json"

      # The above command will returns JSON structured like this:
      {
        "data": {
            "id": "1",
            "type": "users",
            "attributes": {
                "name": "Chris Cross",
                "email": "guadalupe@mcclureheel.biz"
            },
            "relationships": {
                "appointments": {
                    "data": [
                        {
                            "id": "2",
                            "type": "appointments"
                        },
                        ...
                        ...
                        ...
                    ]
                }
            }
        }
      }
    EOS
    param :id, Integer, :desc => "Desirable user to search", :required => true
    returns :code => 200, :desc => "a successful response" do
       property :data, Hash, :desc => "A Hash value"
       property :id, Integer, :desc => "Numeric identifier for an User"
       property :type, String, :desc => "An string value of the record type"
       property :attributes, Hash, :desc => "A Hash with the user infos"
       property :name, String, :desc => "The user name"
       property :email, String, :desc => "The user email"
       property :relationships, Hash, :desc => "Hash with the user relationships"
    end
    def show
      render json: @user
    end

    api :POST, '/users', 'Creates a new user'
    error :code => 406,
      :desc => "Not Acceptable - Due the non accepted 'Accept' header"
    error :code => 415,
      :desc => "Unsupported Media Type - Due the non accepted 'Content-type' header"
    error :code => 422,
      :desc => "Unprocessable Entity - The request was well-formed but with fail user validations when tried to create"
    formats ['application/vnd.api+json']
    example <<-EOS
      curl -X POST "http://localhost:3000/v1/users" \\
        -H "Accept: application/vnd.api+json" \\
        -H "Content-Type: application/vnd.api+json" \\
        -d '{"data":{"type":"users","attributes":{"name":"Andrew Ryan","email":"rapture@city.com"}}}'

      # The above command will returns JSON structured like this:
      {
          "data": {
              "type": "users",
              "attributes": {
                  "name": "Andrew Ryan",
                  "email": "rapturee@city.com"
              },
              "relationships": {
                  "appointments": {
                      "data": []
                  }
              }
          }
      }
    EOS
    param :name, String, :desc => "The user name", :required => true
    param :email, String, :desc => "The user email", :required => true
    returns :code => 201, :desc => "a successful response" do
      property :data, Hash, :desc => "A Hash value"
      property :id, Integer, :desc => "Numeric identifier for an User"
      property :type, String, :desc => "An string value of the record type"
      property :attributes, Hash, :desc => "A Hash with the user infos"
      property :name, String, :desc => "The user name"
      property :email, String, :desc => "The user email"
      property :relationships, Hash, :desc => "Hash with the user relationships"
    end
    def create
      @user = User.new(user_params)

      if @user.save
        render json: @user, status: :created, location: v1_user_url(@user)
      else
        render json: @user.errors, status: :unprocessable_entity
      end
    end


    api :PATCH, '/users/:user_id', 'Updates an user'
    error :code => 404,
      :desc => "Not Found - Couldn't find User with 'id'=<USER_ID>"
    error :code => 406,
      :desc => "Not Acceptable - Due the non accepted 'Accept' header"
    error :code => 415,
      :desc => "Unsupported Media Type - Due the non accepted 'Content-type' header"
    error :code => 422,
      :desc => "Unprocessable Entity - The request was well-formed but fail with user validations when tried to create"
    formats ['application/vnd.api+json']
    example <<-EOS
    curl -X PATCH "http://localhost:3000/v1/users/1" \\
      -H "Accept: application/vnd.api+json" \\
      -H "Content-Type: application/vnd.api+json" \\
      -d '{"data":{"id":"1","type":"users","attributes":{"name":"Atlas Ryan","email":"radio@man.com"}}}'
    ou
    curl -X PUT "http://localhost:3000/v1/users/1" \\
      -H "Accept: application/vnd.api+json" \\
      -H "Content-Type: application/vnd.api+json" \\
      -d '{"data":{"id":"1","type":"users","attributes":{"name":"Atlas Ryan","email":"radio@man.com"}}}'

      # The above command will returns JSON structured like this:
      {
          "data": {
              "id": "<USER_ID>",
              "type": "users",
              "attributes": {
                  "name": "Atlas Ryan",
                  "email": "radio@man.com"
              },
              "relationships": {
                  "appointments": {
                      "data": []
                  }
              }
          }
      }
    EOS
    param :user_id, Integer, :desc => "Desirable user to update", :required => true
    param :name, String, :desc => "The user name", :required => true
    param :email, String, :desc => "The user email", :required => true
    returns :code => 200, :desc => "a successful response" do
      property :data, Hash, :desc => "A Hash value"
      property :id, Integer, :desc => "Numeric identifier for an User"
      property :type, String, :desc => "An string value of the record type"
      property :attributes, Hash, :desc => "A Hash with the user infos"
      property :name, String, :desc => "The user name"
      property :email, String, :desc => "The user email"
      property :relationships, Hash, :desc => "Hash with the user relationships"
    end
    def update
      if @user.update(user_params)
        render json: @user
      else
        render json: @user.errors, status: :unprocessable_entity
      end
    end

    api :DELETE, '/users/:user_id', 'Deletes an user'
    error :code => 404,
      :desc => "Not Found - Couldn't find User with 'id'=<USER_ID>"
    error :code => 406,
      :desc => "Not Acceptable - Due the non accepted 'Accept' header"
    error :code => 415,
      :desc => "Unsupported Media Type - Due the non accepted 'Content-type' header"
    formats ['application/vnd.api+json']
    param :user_id, Integer, :desc => "Desirable user to delete", :required => true
    example <<-EOS
    curl -X DELETE "http://localhost:3000/v1/users/1" \\
      -H "Accept: application/vnd.api+json" \\
      -H "Content-Type: application/vnd.api+json" \\

      # The above command will returns JSON structured like this:
      nothing
    EOS
    returns :code => 204, :desc => "no content response"
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
