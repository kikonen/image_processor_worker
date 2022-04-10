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

    image_url = image[:url]
    file_name = image_url.split('/').last
    image_response = ApiRequest.raw_get(url: image_url)

    output_file_name = File.join(Rails.root, "log", file_name)
    File.open(output_file_name, "wb") do |f|
      f.write(image_response[:content])
    end
    Rails.logger.info "OUT: #{output_file_name}"
  end
end
