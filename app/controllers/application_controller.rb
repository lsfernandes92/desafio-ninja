class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found_response

  def render_not_found_response(exception)
    render json: { error_message: exception.message, error_status: '404' }, status: :not_found
  end
end
