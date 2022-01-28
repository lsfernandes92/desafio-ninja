# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Appointments requests', type: :request do
  let(:user_without_appointment) { create(:user) }
  let(:user_with_appointment) { create(:user_with_appointment) }

  context 'when request with invalid headers' do
    it 'returns status code 406 if no accept header sent' do
      get v1_user_appointments_path(user_without_appointment)
      expect(response).to have_http_status(:not_acceptable)
    end

    it 'returns status code 415 if no content-type header sent' do
      post(v1_user_appointment_path(user_without_appointment), headers: accept_header)
      expect(response).to have_http_status(:unsupported_media_type)
    end
  end

  context 'when resquest with valid headers' do
    describe 'GET /users/:user_id/relationships/appointments' do
      let(:user_first_appointment) { user_with_appointment.appointments.first }

      before do
        get(v1_user_appointments_path(user_with_appointment), headers: accept_header)
      end

      it 'returns users appointments' do
        expect(response).to have_http_status(:ok)
        expect(response_body['data'].count).to eq 1
        expect(response_body['data'].first).to include_json(
          {
            id: (be_kind_of String),
            type: 'appointments',
            attributes: {
              title: user_first_appointment.title,
              notes: user_first_appointment.notes,
              'start-time': (be_kind_of String),
              'end-time': (be_kind_of String)
            }
          }
        )
      end

      it 'returns 404 when user do not exist' do
        get(v1_user_appointments_path(user_id: 999), headers: accept_header)

        expect(response.status).to eq 404
        expect(response_body).to include_json(
          errors: [{
            id: 'record',
            title: "Couldn't find User with 'id'=999"
          }]
        )
      end
    end

    describe 'POST /users/:user_id/relationships/appointment' do
      let(:first_room) { Room.first }
      let(:appointment_params) do
        {
          "data": {
            "type": 'appointments',
            "attributes": {
              "title": 'Foo title',
              "notes": 'Foo note',
              "start_time": '27/01/2022 12:00',
              "end_time": '27/01/2022 13:00',
              "room_id": first_room.id.to_s
            }
          }
        }
      end

      before { create(:room) }

      it 'should create appointment' do
        travel_to Time.zone.local(2022, 1, 26, 9, 0, 0) do
          expect do
            post(
              v1_user_appointment_path(user_without_appointment),
              params: appointment_params.to_json,
              headers: accept_header.merge(content_type_header)
            )
          end.to change { Appointment.count }.by(1)
          expect(response_body).to include_json(
            data: [{
              id: (be_kind_of String),
              type: 'appointments',
              attributes: {
                title: appointment_params.dig(:data, :attributes, :title),
                notes: appointment_params.dig(:data, :attributes, :notes),
                'start-time': (be_kind_of String),
                'end-time': (be_kind_of String)
              }
            }]
          )
          expect(response).to have_http_status :created
        end
      end

      context 'with validations' do
        it 'validates room_id presence' do
          appointment_params[:data][:attributes][:room_id] = ''

          travel_to Time.zone.local(2022, 1, 26, 9, 0, 0) do
            post(
              v1_user_appointment_path(user_without_appointment),
              params: appointment_params.to_json,
              headers: accept_header.merge(content_type_header)
            )
          end
          expect(response_body).to include_json(
            errors: [{
              id: 'room',
              title: 'must exist'
            }]
          )
          expect(response).to have_http_status :unprocessable_entity
        end

        it 'validates title presence' do
          appointment_params[:data][:attributes][:title] = ''

          travel_to Time.zone.local(2022, 1, 26, 9, 0, 0) do
            post(
              v1_user_appointment_path(user_without_appointment),
              params: appointment_params.to_json,
              headers: accept_header.merge(content_type_header)
            )
          end
          expect(response_body).to include_json(
            errors: [{
              id: 'title',
              title: "can't be blank"
            }]
          )
          expect(response).to have_http_status :unprocessable_entity
        end

        it 'validates title length' do
          appointment_params[:data][:attributes][:title] = 'a' * 51

          travel_to Time.zone.local(2022, 1, 26, 9, 0, 0) do
            post(
              v1_user_appointment_path(user_without_appointment),
              params: appointment_params.to_json,
              headers: accept_header.merge(content_type_header)
            )
          end
          expect(response_body).to include_json(
            errors: [{
              id: 'title',
              title: 'is too long (maximum is 50 characters)'
            }]
          )
          expect(response).to have_http_status :unprocessable_entity
        end

        it 'validates notes presence' do
          appointment_params[:data][:attributes][:notes] = ''

          travel_to Time.zone.local(2022, 1, 26, 9, 0, 0) do
            post(
              v1_user_appointment_path(user_without_appointment),
              params: appointment_params.to_json,
              headers: accept_header.merge(content_type_header)
            )
          end
          expect(response_body).to include_json(
            errors: [{
              id: 'notes',
              title: "can't be blank"
            }]
          )
          expect(response).to have_http_status :unprocessable_entity
        end

        it 'validates notes length' do
          appointment_params[:data][:attributes][:notes] = 'a' * 141

          travel_to Time.zone.local(2022, 1, 26, 9, 0, 0) do
            post(
              v1_user_appointment_path(user_without_appointment),
              params: appointment_params.to_json,
              headers: accept_header.merge(content_type_header)
            )
          end
          expect(response_body).to include_json(
            errors: [{
              id: 'notes',
              title: 'is too long (maximum is 140 characters)'
            }]
          )
          expect(response).to have_http_status :unprocessable_entity
        end

        it 'validates start_time presence' do
          appointment_params[:data][:attributes][:start_time] = ''

          travel_to Time.zone.local(2022, 1, 26, 9, 0, 0) do
            post(
              v1_user_appointment_path(user_without_appointment),
              params: appointment_params.to_json,
              headers: accept_header.merge(content_type_header)
            )
          end
          expect(response_body).to include_json(
            errors: [{
              id: 'start_time',
              title: "can't be blank"
            }]
          )
          expect(response).to have_http_status :unprocessable_entity
        end

        it 'start_time should be less than end_time' do
          appointment_params[:data][:attributes][:start_time] = '27/01/2022 14:00'

          travel_to Time.zone.local(2022, 1, 26, 9, 0, 0) do
            post(
              v1_user_appointment_path(user_without_appointment),
              params: appointment_params.to_json,
              headers: accept_header.merge(content_type_header)
            )
          end
          expect(response_body).to include_json(
            errors: [{
              id: 'start_time',
              title: 'must be less than end_time'
            }]
          )
          expect(response).to have_http_status :unprocessable_entity
        end

        it 'validates end_time presence' do
          appointment_params[:data][:attributes][:end_time] = ''

          travel_to Time.zone.local(2022, 1, 26, 9, 0, 0) do
            post(
              v1_user_appointment_path(user_without_appointment),
              params: appointment_params.to_json,
              headers: accept_header.merge(content_type_header)
            )
          end
          expect(response_body).to include_json(
            errors: [{
              id: 'end_time',
              title: "can't be blank"
            }]
          )
          expect(response).to have_http_status :unprocessable_entity
        end

        it 'start_time and end_time should be on weekday' do
          appointment_params[:data][:attributes][:start_time] = '29/01/2022 12:00'
          appointment_params[:data][:attributes][:end_time] = '29/01/2022 13:00'

          travel_to Time.zone.local(2022, 1, 26, 9, 0, 0) do
            post(
              v1_user_appointment_path(user_without_appointment),
              params: appointment_params.to_json,
              headers: accept_header.merge(content_type_header)
            )
          end
          expect(response_body).to include_json(
            errors: [
              {
                id: 'start_time',
                title: 'must be on week days'
              },
              {
                id: 'end_time',
                title: 'must be on week days'
              }
            ]
          )
          expect(response).to have_http_status :unprocessable_entity
        end

        it 'start_time should be in business hour' do
          appointment_params[:data][:attributes][:start_time] = '27/01/2022 8:00'

          travel_to Time.zone.local(2022, 1, 26, 9, 0, 0) do
            post(
              v1_user_appointment_path(user_without_appointment),
              params: appointment_params.to_json,
              headers: accept_header.merge(content_type_header)
            )
          end
          expect(response_body).to include_json(
            errors: [{
              id: 'start_time',
              title: 'must be during business hours'
            }]
          )
          expect(response).to have_http_status :unprocessable_entity
        end

        it 'end_time should be in business hour' do
          appointment_params[:data][:attributes][:end_time] = '27/01/2022 18:00'

          travel_to Time.zone.local(2022, 1, 26, 9, 0, 0) do
            post(
              v1_user_appointment_path(user_without_appointment),
              params: appointment_params.to_json,
              headers: accept_header.merge(content_type_header)
            )
          end
          expect(response_body).to include_json(
            errors: [{
              id: 'end_time',
              title: 'must be during business hours'
            }]
          )
          expect(response).to have_http_status :unprocessable_entity
        end

        it 'start_time and end_time should be on same day' do
          appointment_params[:data][:attributes][:start_time] = '27/01/2022 9:00'
          appointment_params[:data][:attributes][:end_time] = '28/01/2022 10:00'

          travel_to Time.zone.local(2022, 1, 26, 9, 0, 0) do
            post(
              v1_user_appointment_path(user_without_appointment),
              params: appointment_params.to_json,
              headers: accept_header.merge(content_type_header)
            )
          end
          expect(response_body).to include_json(
            errors: [{
              id: 'appointment',
              title: 'must be on same day'
            }]
          )
          expect(response).to have_http_status :unprocessable_entity
        end

        it 'validates if appointment time already took' do
          appointment = create(:appointment)
          appointment_params[:data][:attributes][:start_time] = '26/12/2022 12:00'
          appointment_params[:data][:attributes][:end_time] = '26/12/2022 13:00'
          appointment_params[:data][:attributes][:room_id] = appointment.room.id.to_s

          travel_to Time.zone.local(2022, 1, 26, 9, 0, 0) do
            post(
              v1_user_appointment_path(user_with_appointment),
              params: appointment_params.to_json,
              headers: accept_header.merge(content_type_header)
            )
          end
          expect(response_body).to include_json(
            errors: [{
              id: 'appointment',
              title: 'already took'
            }]
          )
          expect(response).to have_http_status :unprocessable_entity
        end

        it 'appointment should be on future date and time' do
          appointment_params[:data][:attributes][:start_time] = '25/01/2022 12:00'
          appointment_params[:data][:attributes][:end_time] = '25/01/2022 13:00'

          travel_to Time.zone.local(2022, 1, 26, 9, 0, 0) do
            post(
              v1_user_appointment_path(user_without_appointment),
              params: appointment_params.to_json,
              headers: accept_header.merge(content_type_header)
            )
          end
          expect(response_body).to include_json(
            errors: [{
              id: 'appointment',
              title: 'must be in future date'
            }]
          )
          expect(response).to have_http_status :unprocessable_entity
        end
      end
    end

    describe 'PATCH/PUT /users/:user_id/relationships/appointment' do
      let(:record_to_update) { create(:appointment) }
      let(:appointment_params) do
        {
          "data": {
            "id": record_to_update.id.to_s,
            "type": 'appointments',
            "attributes": {
              "title": 'Título maneiro',
              "notes": 'Nota secreta',
              "start_time": '27/01/2022 12:00',
              "end_time": '27/01/2022 13:00'
            }
          },
          "id": record_to_update.id.to_s
        }
      end

      context 'with valid params' do
        before do
          travel_to Time.zone.local(2022, 1, 26, 9, 0, 0) do
            patch(
              v1_user_appointment_path(record_to_update.user),
              params: appointment_params.to_json,
              headers: accept_header.merge(content_type_header)
            )
          end
          record_to_update.reload
        end

        it 'updates the appointment' do
          expect(record_to_update.title).to eq('Título maneiro')
          expect(record_to_update.notes).to eq('Nota secreta')
          expect(response).to have_http_status :ok
        end
      end

      context 'with invalid params' do
        before do
          appointment_params[:data][:attributes][:title] = ''
          appointment_params[:data][:attributes][:notes] = ''
          appointment_params[:data][:attributes][:start_time] = ''
          appointment_params[:data][:attributes][:end_time] = ''
          appointment_params[:data][:attributes][:room_id] = ''

          patch(
            v1_user_appointment_path(record_to_update.user),
            params: appointment_params.to_json,
            headers: accept_header.merge(content_type_header)
          )
          record_to_update.reload
        end

        it 'should not update the appointment' do
          expect(response_body).to include_json(
            errors: [
              {
                id: 'room',
                title: 'must exist'
              },
              {
                id: 'title',
                title: "can't be blank"
              },
              {
                id: 'notes',
                title: "can't be blank"
              },
              {
                id: 'start_time',
                title: "can't be blank"
              },
              {
                id: 'end_time',
                title: "can't be blank"
              }
            ]
          )
          expect(response).to have_http_status :unprocessable_entity
        end
      end

      context 'when appointment don\'t belong to user' do
        let(:user_not_owner) { create(:user) }

        before do
          travel_to Time.zone.local(2022, 1, 26, 9, 0, 0) do
            patch(
              v1_user_appointment_path(user_not_owner),
              params: appointment_params.to_json,
              headers: accept_header.merge(content_type_header)
            )
          end
          record_to_update.reload
        end

        it 'should not updates the appointment' do
          expect(response_body).to include_json(
            errors: [{
              id: 'appointment',
              title: "don't belong to user"
            }]
          )
          expect(response).to have_http_status :unprocessable_entity
        end
      end
    end

    describe 'DELETE /users/:user_id/relationships/appointment' do
      let(:appointment_to_destroy) { create(:appointment) }
      let(:appointment_params) do
        {
          "data": {
            "id": appointment_to_destroy.id.to_s
          }
        }
      end

      before { appointment_to_destroy }

      it 'deletes the appointment' do
        expect do
          delete(
            v1_user_appointment_path(appointment_to_destroy.user),
            params: appointment_params.to_json,
            headers: accept_header.merge(content_type_header)
          )
        end.to change { Appointment.count }.by(-1)
        expect(response).to have_http_status :no_content
      end

      it 'should not delete an invalid appointment ' do
        appointment_params[:data][:id] = '999'

        expect do
          delete(
            v1_user_appointment_path(appointment_to_destroy.user),
            params: appointment_params.to_json,
            headers: accept_header.merge(content_type_header)
          )
        end.to change { User.count }.by(0)
        expect(response).to have_http_status :not_found
        expect(response_body).to include_json(
          errors: [{
            id: 'record',
            title: "Couldn't find Appointment with 'id'=999"
          }]
        )
      end
    end
  end
end
