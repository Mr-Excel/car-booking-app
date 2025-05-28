require 'net/http'
require 'uri'
require 'json'

module CarBooking
  class SDK
    attr_reader :base_url, :api_key, :tenant_id

    def initialize(base_url, api_key = nil, tenant_id = nil)
      @base_url = base_url
      @api_key = api_key
      @tenant_id = tenant_id
    end

    # Authentication methods
    def login(email, password)
      post('/sessions', { email: email, password: password })
    end

    def register(user_params)
      post('/users', { user: user_params })
    end

    def register_guest(guest_params)
      post('/guest_users', { guest_user: guest_params })
    end

    # Booking methods
    def get_bookings(params = {})
      get('/bookings', params)
    end

    def get_booking(id)
      get("/bookings/#{id}")
    end

    def create_booking(booking_params)
      post('/bookings', { booking: booking_params })
    end

    def update_booking(id, booking_params)
      put("/bookings/#{id}", { booking: booking_params })
    end

    def cancel_booking(id)
      delete("/bookings/#{id}")
    end

    # Payment methods
    def process_payment(payment_params)
      post('/payments', { payment: payment_params })
    end

    # Vehicle methods
    def get_vehicles(params = {})
      get('/vehicles', params)
    end

    private

    def get(path, params = {})
      uri = URI.parse("#{@base_url}#{path}")
      uri.query = URI.encode_www_form(params) if params.any?
      
      request = Net::HTTP::Get.new(uri)
      add_headers(request)
      
      make_request(uri, request)
    end

    def post(path, body = {})
      uri = URI.parse("#{@base_url}#{path}")
      request = Net::HTTP::Post.new(uri)
      add_headers(request)
      request.body = body.to_json
      
      make_request(uri, request)
    end

    def put(path, body = {})
      uri = URI.parse("#{@base_url}#{path}")
      request = Net::HTTP::Put.new(uri)
      add_headers(request)
      request.body = body.to_json
      
      make_request(uri, request)
    end

    def delete(path)
      uri = URI.parse("#{@base_url}#{path}")
      request = Net::HTTP::Delete.new(uri)
      add_headers(request)
      
      make_request(uri, request)
    end

    def add_headers(request)
      request['Content-Type'] = 'application/json'
      request['Accept'] = 'application/json'
      request['X-API-Key'] = @api_key if @api_key
      request['X-Tenant-ID'] = @tenant_id if @tenant_id
    end

    def make_request(uri, request)
      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
        http.request(request)
      end

      parse_response(response)
    end

    def parse_response(response)
      case response
      when Net::HTTPSuccess
        begin
          JSON.parse(response.body)
        rescue JSON::ParserError
          { success: true, body: response.body }
        end
      else
        begin
          error_data = JSON.parse(response.body)
          { success: false, status: response.code, error: error_data }
        rescue JSON::ParserError
          { success: false, status: response.code, error: response.body }
        end
      end
    end
  end
end 