# frozen_string_literal: true

class ApiRequest
  HEADER_BEARER = 'Bearer'
  HEADER_ACCEPT = 'Accept'
  HEADER_CONTENT_TYPE = 'Content-Type'
  HEADER_CONTENT_TYPE_HTTP2 = 'content-type'

  CONTENT_TYPE_JSON = 'application/json'

  HEAD_HTTP_RESPONSE= 'HTTP/'

  HTTP_SUCCESS_FIRST = 100
  HTTP_ERROR_FIRST = 400
  HTTP_NOT_FOUND = 404

  HTTP_SUCCESS_RANGE = (HTTP_SUCCESS_FIRST...HTTP_ERROR_FIRST)

  def initialize
    @base_url = ENV['API_BASE_URL'].gsub(/\/\z/, '')
  end

  def get(
        url:,
        token:,
        query: nil,
        accept_content_type: CONTENT_TYPE_JSON)
    do_request(
      http_method: :get,
      url: url,
      token: token,
      query: query,
      accept_content_type: accept_content_type)
  end

  def post(
        url:,
        token:,
        query: nil,
        body: nil,
        accept_content_type: CONTENT_TYPE_JSON)
    do_request(
      http_method: :post,
      url: url,
      token: token,
      query: query,
      body: body,
      accept_content_type: accept_content_type)
  end

  def put(
        url:,
        token:,
        query: nil,
        body: nil,
        accept_content_type: CONTENT_TYPE_JSON)
    do_request(
      http_method: :put,
      url: url,
      token: token,
      query: query,
      body: body,
      accept_content_type: accept_content_type)
  end

  def do_request(
        http_method:,
        url:,
        token:,
        query: nil,
        body: nil,
        request_content_type: CONTENT_TYPE_JSON,
        accept_content_type: CONTENT_TYPE_JSON)

    url_sep = url.start_with?('/') ? '' : '/'
    request_url = "#{@base_url}#{url_sep}#{url}"

    encoded_body = encode_payload(:json, body)
    encoded_query = encode_payload(:query, query)

    request_headers = {
      HEADER_BEARER => token,
      HEADER_CONTENT_TYPE => request_content_type,
      HEADER_ACCEPT => accept_content_type,
    }

    response_status = nil
    response_body = nil
    response_content_type = nil
    response_content_type = nil
    begin
      curl = Curl::Easy.new

      request_headers.each do |key, value|
        curl.headers[key] = value
      end

      curl.url = encoded_query ? "#{request_url}?#{encoded_query}" : request_url

      curl.on_header do |data|
        if data.start_with?(HEAD_HTTP_RESPONSE)
          response_status = data.split(' ')[1].to_i
        elsif data.start_with?(HEADER_CONTENT_TYPE_HTTP2) || data.start_with?(HEADER_CONTENT_TYPE)
          response_content_type = data.split(':')[1].split(';')[0].strip
        end
        data.size
      end

      curl_call = ->() {
        case http_method
        when :get
          curl.http_get
        when :put
          curl.http_put(encoded_body)
        when :delete
          curl.http_delete
        when :post
          curl.post_body = encoded_body
          curl.http_post
        end
      }

      Rails.logger.info "#{http_method} #{request_url}\n#{encoded_body}"

      curl_call.call
      response_body = curl.body_str
      curl.close
    end

    ApiResponse.new(
      status: response_status,
      content_type: response_content_type,
      content: decode_response(response_content_type, response_body),
    )
  end

  def raw_request(
        http_method: :get,
        url:,
        query: nil,
        body: nil,
        request_content_type: CONTENT_TYPE_JSON,
        accept_content_type: CONTENT_TYPE_JSON)
    encoded_body = encode_payload(:json, body)
    encoded_query = encode_payload(:query, query)

    request_url = url

    response_status = nil
    response_body = nil
    response_content_type = nil
    begin
      curl = Curl::Easy.new
      curl.url = encoded_query ? "#{request_url}?#{encoded_query}" : request_url

      curl.on_header do |data|
        if data.start_with?(HEAD_HTTP_RESPONSE)
          response_status = data.split(' ')[1].to_i
        elsif data.start_with?(HEADER_CONTENT_TYPE_HTTP2) || data.start_with?(HEADER_CONTENT_TYPE)
          response_content_type = data.split(':')[1].split(';')[0].strip
        end
        data.size
      end

      curl_call = ->() {
        case http_method
        when :get
          curl.http_get
        when :put
          curl.http_put(encoded_body)
        when :delete
          curl.http_delete
        when :post
          curl.post_body = encoded_body
          curl.http_post
        end
      }

      Rails.logger.info "#{http_method} #{request_url}"

      curl_call.call
      response_body = curl.body_str
      curl.close
    end

    ApiResponse.new(
      status: response_status,
      content_type: response_content_type,
      content: response_body,
    )
  end

  def encode_payload(request_content_type, data)
    return nil if data.nil?

    case request_content_type
    when :json
      Util.encode_json(data)
    when :query
      data.to_query
    else
      data
    end
  end

  def decode_response(response_content_type, data)
    return nil if data.nil?

    case response_content_type
    when CONTENT_TYPE_JSON
      Util.decode_json(data)
    else
      data
    end
  end

end
