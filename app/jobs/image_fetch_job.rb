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

    image_response = nil
    begin
      image_url = image[:url]
      file_name = image_url.split('/').last
      image_response = ApiRequest.new.raw_request(url: image_url)

      output_file_name = File.join(Rails.root, "log", file_name)
      File.open(output_file_name, "wb") do |f|
        f.write(image_response[:content])
      end
      Rails.logger.info "OUT: #{output_file_name}"
    end

    begin
      exif_values = fetch_exif_values(image_response)
      update_data = {
        image: {
          status: :fetched,
          mime_type: image_response[:mime_type],
          exif_values: exif_values,
        }
      }

      update_response = request.put(
        url: "/images/#{image_id}",
        token: Token.create_system_token,
        body: update_data)
    end
  end

  def fetch_exif_values(image_response)
    data = Exif::Data.new(image_response[:content])

    # NOTE KI data CAN and WILL contain invalid characters
    data[:exif].map do |k, v|
      {
        key: k,
        value: v.is_a?(String) ? v.gsub(/[^[:print:]]/,'.') : v
      }
    end
  end
end
