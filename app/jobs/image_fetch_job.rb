# frozen_string_literal: true

class ImageFetchJob < ApplicationJob
  queue_as :image_fetch

  def perform(params)
    image_id = params[:image_id]
    Rails.logger.info "IMAGE_FETCH: #{image_id}"

    api = ApiRequest.new
    response = api.get(
      url: "/images/#{image_id}",
      token: Token.create_system_token)

    raise "not found" unless response.success?

    image = response.content
    Rails.logger.info image

    image_response = nil
    image_status = :failed
    begin
      image_url = image[:url]
      file_name = image_url.split('/').last
      image_response = api.raw_request(url: image_url)

      output_file_name = File.join(Rails.root, "log", file_name)
      File.open(output_file_name, "wb") do |f|
        f.write(image_response.content)
      end
      image_status = :fetched
      Rails.logger.info "OUT: #{output_file_name}"
    rescue => e
      Rails.logger.error e
    end

    begin
      exif_values = fetch_exif_values(image_response) if status != :failed
      update_data = {
        image: {
          status: image_status,
          mime_type: image_response.content_type,
          exif_values: exif_values,
        }
      }

      update_response = api.put(
        url: "/images/#{image_id}",
        token: Token.create_system_token,
        body: update_data)
    end
  end

  def fetch_exif_values(image_response)
    data = Exif::Data.new(image_response.content)

    # NOTE KI data CAN and WILL contain invalid characters
    data[:exif].map do |k, v|
      {
        key: k,
        value: v.is_a?(String) ? v.gsub(/[^[:print:]]/,'.') : v
      }
    end
  rescue Exif::NotReadable => e
    Rails.logger.error e
    nil
  rescue => e
    Rails.logger.error e
    nil
  end
end
