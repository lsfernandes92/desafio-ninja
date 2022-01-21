require 'rails_helper'

RSpec.describe 'Users', type: :request do
  before do
    create_list(:user, 2)
  end

  let(:response_body) { JSON.parse(response.body) }

  describe 'GET /users' do
    before do
      get '/users'
    end

    it 'returns users info' do
      expect(response).to have_http_status(:ok)
      expect(response_body['data'].count).to eq 2
    end
  end

  describe 'GET /users/:id' do
    let(:first_user) { User.first }

    it 'returns only first user' do
      get user_path(first_user)

      expect(response_body).to include_json(
        data: {
          id: (be_kind_of String),
          type: 'users',
          attributes: {
            name: first_user.name,
            email: first_user.email
          }
        }
      )
    end

    it 'returns 404 when user do not exist' do
      get '/users/999'

      expect(response.status).to eq 404
      expect(response_body).to include_json(
        error_message: "Couldn't find User with 'id'=999",
        error_status: '404'
      )
    end
  end

  describe 'POST /users' do
    let(:foo_user_params) { {
      "data": {
        "attributes": {
            "name": "Foo User",
            "email": "foo@user.io"
        }
      }
    } }

    it 'should create user' do
      expect{ post users_path(foo_user_params) }.to change{ User.count }.by(1)
      expect(response_body).to include_json(
        data: {
          id: (be_kind_of String),
          type: 'users',
          attributes: {
            name: foo_user_params.dig(:data, :attributes, :name),
            email: foo_user_params.dig(:data, :attributes, :email)
          }
        }
      )
      expect(response).to have_http_status :created
    end

    context 'with validations' do
      it 'name should be present' do
        foo_user_params[:data][:attributes][:name] = ''

        expect{ post users_path(foo_user_params) }.to change{ User.count }.by(0)
        expect(response_body['name']).to match_array(["can't be blank"])
        expect(response).to have_http_status :unprocessable_entity
      end

      it 'name should not be too long' do
        foo_user_params[:data][:attributes][:name] = "a" * 51

        expect{ post users_path(foo_user_params) }.to change{ User.count }.by(0)
        expect(response_body['name']).to match_array(
          ["is too long (maximum is 50 characters)"]
        )
        expect(response).to have_http_status :unprocessable_entity
      end

      it 'email should be present' do
        foo_user_params[:data][:attributes][:email] = ''

        expect{ post users_path(foo_user_params) }.to change{ User.count }.by(0)
        expect(response_body['email']).to match_array(
          ["can't be blank", "is invalid"]
        )
        expect(response).to have_http_status :unprocessable_entity
      end

      it 'email should not be too long' do
        foo_user_params[:data][:attributes][:email] = "a" * 244 + "@example.com.br"

        expect{ post users_path(foo_user_params) }.to change{ User.count }.by(0)
        expect(response_body['email']).to match_array(
          ["is too long (maximum is 255 characters)"]
        )
        expect(response).to have_http_status :unprocessable_entity
      end

      it 'rejects invalid email addresses' do
        foo_user_params[:data][:attributes][:email] = "umemailnaovalido"

        expect{ post users_path(foo_user_params) }.to change{ User.count }.by(0)
        expect(response_body['email']).to match_array(["is invalid"])
        expect(response).to have_http_status :unprocessable_entity
      end

      it 'email address should be unique' do
        duplicate_user = User.create(name: 'test', email: 'email@email.com')
        foo_user_params[:data][:attributes][:email] = duplicate_user.email

        expect{ post users_path(foo_user_params) }.to change{ User.count }.by(0)
        expect(response_body['email']).to match_array(["has already been taken"])
        expect(response).to have_http_status :unprocessable_entity
      end

      it 'email should be saved in lower case' do
        mixed_case_email = 'FoO@eXaMpLe.com.br'
        foo_user_params[:data][:attributes][:email] = mixed_case_email

        expect{ post users_path(foo_user_params) }.to change{ User.count }.by(1)
        expect(response_body['data']['attributes']['email']).to eq mixed_case_email.downcase
        expect(response).to have_http_status :created
      end
    end

    describe 'PATCH/PUT /users/:id' do
      let(:record_to_update) { create(:user) }
      let(:user_params) { {
        "data": {
          "id": "#{record_to_update.id}",
          "attributes": {
            "name": "Goku",
            "email": "goku@bol.com"
          }
        },
        "id": "#{record_to_update.id}"
      } }

      context 'with valid params' do
        before do
          patch user_path(user_params)
          record_to_update.reload
        end

        it 'updates the user' do
          expect(record_to_update.name).to eq('Goku')
          expect(record_to_update.email).to eq('goku@bol.com')
          expect(response).to have_http_status :ok
        end
      end

      context 'with invalid params' do
        before do
          user_params[:data][:attributes][:name] = ''
          user_params[:data][:attributes][:email] = ''

          patch user_path(user_params)
          record_to_update.reload
        end

        it 'should not update the user' do
          expect(response_body['name']).to match_array(["can't be blank"])
          expect(response_body['email']).to match_array(
            ["can't be blank", "is invalid"]
          )
          expect(response).to have_http_status :unprocessable_entity
        end
      end
    end

  end

  describe 'DELETE /users/:user_id' do
    let(:user_to_destroy) { create(:user) }

    before { user_to_destroy }

    it 'deletes the user' do
      expect{ delete user_path(user_to_destroy) }.to change{ User.count }.by(-1)
      expect(response).to have_http_status :no_content
    end

    it 'should not delete an invalid user ' do
      expect{ delete '/users/999' }.to change{ User.count }.by(0)
      expect(response).to have_http_status :not_found
      expect(response_body).to include_json(
        error_message: "Couldn't find User with 'id'=999",
        error_status: '404'
      )
    end
  end
end
