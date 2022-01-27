# frozen_string_literal: true

module JsonHelpers
  def response_body
    JSON.parse(response.body)
  end
end
