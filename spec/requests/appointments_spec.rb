require 'rails_helper'

RSpec.describe "Appointments requests", type: :request do
  let(:accept_header) { { "Accept": 'application/vnd.api+json' } }
  let(:content_type_header) { { "Content-Type": 'application/vnd.api+json' } }
  let(:user) { create(:user_with_appointments) }

  context 'when request with invalid headers' do
    it 'returns status code 406 if no accept header sent' do
      byebug
      get v1_user_appointments(user)
      expect(response).to have_http_status(:not_acceptable)
    end

    it 'returns status code 415 if no content-type header sent' do
      post('/v1/users', headers: accept_header)
      expect(response).to have_http_status(:unsupported_media_type)
    end
  end
end
