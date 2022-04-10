# frozen_string_literal: true

class ImageFetchJob < ApplicationJob
  queue_as :image_fetch

  def perform(params)
    image_id = params[:image_id]
    Rails.logger.info "IMAGE_FETCH: #{image_id}"

    request = ApiRequest.new
    image = request.get(
      url: "/images/#{image_id}",
      token: Token.create_system_token)

    Rails.logger.info image
  end
end
