# frozen_string_literal: true

class ApiRequest
  HEADER_BEARER = 'Bearer'
  HEADER_ACCEPT = 'Accept'
  HEADER_CONTENT_TYPE = 'Content-Type'
  HEADER_CONTENT_TYPE_HTTP2 = 'content-type'

  CONTENT_JSON = 'application/json'

  HEAD_HTTP_RESPONSE= 'HTTP/'


  def initialize
    @base_url = ENV['API_BASE_URL'].gsub(/\/\z/, '')
  end

  def get(
        url:,
        token:,
        query: nil,
        accept_mime_type: CONTENT_JSON)
    do_request(
      http_method: :get,
      url: url,
      token: token,
      query: query,
      accept_mime_type: accept_mime_type)
  end

  def post(
        url:,
        token:,
        query: nil,
        body: nil,
        accept_mime_type: CONTENT_JSON)
    do_request(
      http_method: :post,
      url: url,
      token: token,
      query: query,
      body: body,
      accept_mime_type: accept_mime_type)
  end

  def put(
        url:,
        token:,
        query: nil,
        body: nil,
        accept_mime_type: CONTENT_JSON)
    do_request(
      http_method: :put,
      url: url,
      token: token,
      query: query,
      body: body,
      accept_mime_type: accept_mime_type)
  end

  def do_request(
        http_method:,
        url:,
        token:,
        query: nil,
        body: nil,
        request_mime_type: CONTENT_JSON,
        accept_mime_type: CONTENT_JSON)

    url_sep = url.start_with?('/') ? '' : '/'
    request_url = "#{@base_url}#{url_sep}#{url}"

    encoded_body = encode_payload(body, :json)
    encoded_query = encode_payload(:query, query)

    request_headers = {
      HEADER_BEARER => token,
      HEADER_CONTENT_TYPE => request_mime_type,
      HEADER_ACCEPT => accept_mime_type,
    }

    response_status = nil
    response_body = nil
    response_mime_type = nil
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
          response_mime_type = data.split(':')[1].split(';')[0].strip
        end
        data.size
      end

      curl_call = ->() {
        case http_method
        when :get
          curl.http_get
        when :put
          curl.http_put(encoded_payload)
        when :delete
          curl.http_delete
        when :post
          curl.post_body = encoded_payload
          curl.http_post
        end
      }

      Rails.logger.info "#{http_method} #{request_url}"

      curl_call.call
      response_body = curl.body_str
      curl.close
    end

    Util.decode_json(response_body)
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

end
