# frozen_string_literal: true

class ApiResponse
  attr_reader :status, :content_type, :content

  def initialize(
        status:,
        content_type:,
        content:)
    @status = status
    @content_type = content_type
    @content = content
  end

  def success?
    ApiRequest::HTTP_SUCCESS_RANGE === @status
  end

  def fail?
    !success?
  end

  def not_found?
    ApiRequest::HTTP_NOT_FOUND == @status
  end

end
