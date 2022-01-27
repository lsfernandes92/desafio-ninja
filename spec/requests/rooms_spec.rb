require 'rails_helper'

RSpec.describe "Room requests", type: :request do
  let(:first_room) { Room.first }

  before do
    create_list(:room, 4)
  end

  context 'when request with invalid headers' do
    it 'returns status code 406 if no accept header sent' do
      get v1_room_path(first_room)
      expect(response).to have_http_status(:not_acceptable)
    end

    it 'returns status code 415 if no content-type header sent' do
      post(v1_rooms_path, headers: accept_header)
      expect(response).to have_http_status(:unsupported_media_type)
    end
  end

  context 'when resquest with valid headers' do
    describe 'GET /rooms/:id' do
      it 'returns only first room' do
        get(v1_room_path(first_room), headers: accept_header)
        expect(response_body).to include_json(
          data: {
            id: (be_kind_of String),
            type: 'rooms',
            attributes: {
              name: first_room.name
            }
          }
        )
      end

      it 'returns 404 when room do not exist' do
        get('/v1/rooms/999', headers: accept_header)

        expect(response.status).to eq 404
        expect(response_body).to include_json(
          error_message: "Couldn't find Room with 'id'=999",
          error_status: '404'
        )
      end
    end

    describe 'POST /rooms' do
      let(:foo_room_params) do
        {
          "data": {
            "attributes": {
              "name": 'Foo Room'
            }
          }
        }
      end

      it 'should create room' do
        expect do
          post(
            v1_rooms_path,
            params: foo_room_params.to_json,
            headers: accept_header.merge(content_type_header)
          )
        end.to change { Room.count }.by(1)
        expect(response_body).to include_json(
          data: {
            id: (be_kind_of String),
            type: 'rooms',
            attributes: {
              name: foo_room_params.dig(:data, :attributes, :name)
            }
          }
        )
        expect(response).to have_http_status :created
      end

      context 'with validations' do
        it 'name should be present' do
          foo_room_params[:data][:attributes][:name] = ''

          expect do
            post(
              v1_rooms_path,
              params: foo_room_params.to_json,
              headers: accept_header.merge(content_type_header)
            )
          end.to change { Room.count }.by(0)
          expect(response_body['name']).to match_array(["can't be blank"])
          expect(response).to have_http_status :unprocessable_entity
        end

        it 'name should not be too long' do
          foo_room_params[:data][:attributes][:name] = 'a' * 51

          expect do
            post(
              v1_rooms_path,
              params: foo_room_params.to_json,
              headers: accept_header.merge(content_type_header)
            )
          end.to change { Room.count }.by(0)
          expect(response_body['name']).to match_array(
            ['is too long (maximum is 50 characters)']
          )
          expect(response).to have_http_status :unprocessable_entity
        end
      end
    end

    describe 'PATCH/PUT /rooms/:id' do
      let(:record_to_update) { create(:room) }
      let(:room_params) do
        {
          "data": {
            "id": record_to_update.id.to_s,
            "attributes": {
              "name": 'Coquinha'
            }
          },
          "id": record_to_update.id.to_s
        }
      end

      context 'with valid params' do
        before do
          patch(
            v1_room_path(room_params),
            params: room_params.to_json,
            headers: accept_header.merge(content_type_header)
          )
          record_to_update.reload
        end

        it 'updates the room' do
          expect(record_to_update.name).to eq('Coquinha')
          expect(response).to have_http_status :ok
        end
      end

      context 'with invalid params' do
        before do
          room_params[:data][:attributes][:name] = ''

          patch(
            v1_room_path(room_params),
            params: room_params.to_json,
            headers: accept_header.merge(content_type_header)
          )
          record_to_update.reload
        end

        it 'should not update the room' do
          expect(response_body['name']).to match_array(["can't be blank"])
          expect(response).to have_http_status :unprocessable_entity
        end
      end
    end

    describe 'DELETE /users/:user_id' do
      let(:room_to_destroy) { create(:room) }

      before { room_to_destroy }

      it 'deletes the room' do
        expect do
          delete(
            v1_room_path(room_to_destroy),
            headers: accept_header.merge(content_type_header)
          )
        end.to change { Room.count }.by(-1)
        expect(response).to have_http_status :no_content
      end

      it 'should not delete an invalid room ' do
        expect do
          delete(
            v1_room_path(999),
            headers: accept_header.merge(content_type_header)
          )
        end.to change { Room.count }.by(0)
        expect(response).to have_http_status :not_found
        expect(response_body).to include_json(
          error_message: "Couldn't find Room with 'id'=999",
          error_status: '404'
        )
      end
    end
  end
end
