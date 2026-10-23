module InstagramConcern
  extend ActiveSupport::Concern

  def instagram_client
    ::OAuth2::Client.new(
      client_id,
      client_secret,
      {
        site: 'https://api.instagram.com',
        authorize_url: 'https://www.instagram.com/oauth/authorize',
        token_url: 'https://api.instagram.com/oauth/access_token',
        auth_scheme: :request_body,
        token_method: :post
      }
    )
  end

  private

  def client_id
    GlobalConfigService.load('INSTAGRAM_APP_ID', nil)
  end

  def client_secret
    GlobalConfigService.load('INSTAGRAM_APP_SECRET', nil)
  end

  def exchange_for_long_lived_token(short_lived_token)
    endpoint = 'https://graph.instagram.com/access_token'
    params = {
      grant_type: 'ig_exchange_token',
      client_secret: client_secret,
      access_token: short_lived_token,
      client_id: client_id
    }

    make_api_request(endpoint, params, 'Failed to exchange token')
  end

  def fetch_instagram_user_details(access_token)
    Instagram::UserDetailsService.new(access_token: access_token).perform
  end

  def make_api_request(endpoint, params, error_prefix)
    # Meta Graph API requires POST for token exchange endpoints to prevent secret leakage in query strings.
    # We attempt POST first, and fallback to GET or sanitized params if needed.
    response = HTTParty.post(
      endpoint,
      body: params,
      headers: {
        'Accept' => 'application/json',
        'Content-Type' => 'application/x-www-form-urlencoded'
      }
    )

    # Fallback to GET if endpoint explicitly demands GET
    if !response.success? && response.body.to_s.include?('method type: post')
      response = HTTParty.get(
        endpoint,
        query: params,
        headers: { 'Accept' => 'application/json' }
      )
    end

    # Fallback to POST without client_id if Meta rejected unexpected parameter
    if !response.success? && params[:client_id].present?
      params_without_client_id = params.reject { |k, _| k.to_s == 'client_id' }
      alt_response = HTTParty.post(
        endpoint,
        body: params_without_client_id,
        headers: {
          'Accept' => 'application/json',
          'Content-Type' => 'application/x-www-form-urlencoded'
        }
      )
      response = alt_response if alt_response.success?
    end

    unless response.success?
      Rails.logger.error "#{error_prefix}. Status: #{response.code}, Body: #{response.body}"
      raise "#{error_prefix}: #{response.body}"
    end

    begin
      JSON.parse(response.body)
    rescue JSON::ParserError => e
      ChatwootExceptionTracker.new(e).capture_exception
      Rails.logger.error "Invalid JSON response: #{response.body}"
      raise e
    end
  end

  def base_url
    ENV.fetch('FRONTEND_URL', 'http://localhost:3000')
  end
end
