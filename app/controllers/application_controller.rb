# frozen_string_literal: true

class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found_response

  before_action :ensure_client_responsability
  before_action :ensure_server_responsability

  def render_not_found_response(exception)
    render json: { error_message: exception.message, error_status: '404' }, status: :not_found
  end

  def ensure_client_responsability
    return if accept?

    render nothing: true, status: :not_acceptable
  end

  def ensure_server_responsability
    unless request.get?
      return if content_type?

      render nothing: true, status: :unsupported_media_type
    end
  end

  private

  def accept?
    request.headers['Accept'] == 'application/vnd.api+json'
  end

  def content_type?
    request.headers['Content-Type'] == 'application/vnd.api+json'
  end
end
