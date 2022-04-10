# frozen_string_literal: true

#
# IMPLEMENTATION of job
#
class ImageFetchJob < ApplicationJob
  queue_as :image_fetch

  def perform(*args)
    puts "IMAGE_FETCH: #{args}"
    Rails.logger.info "IMAGE_FETCH"
    Rails.logger.info args
  end
end
