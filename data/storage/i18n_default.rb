# Force Spanish (:es) as default locale for ActionMailer and Devise mailers
Rails.application.config.i18n.default_locale = :es
I18n.default_locale = :es

Rails.application.config.to_prepare do
  begin
    require_dependency Rails.root.join('app/controllers/concerns/instagram_concern.rb').to_s
  rescue StandardError => e
    Rails.logger.error("Error loading InstagramConcern: #{e.message}")
  end

  if defined?(InstagramConcern)
    InstagramConcern.module_eval do
      def make_api_request(endpoint, params, error_prefix)
        response = HTTParty.post(
          endpoint,
          body: params,
          headers: {
            'Accept' => 'application/json',
            'Content-Type' => 'application/x-www-form-urlencoded'
          }
        )

        if !response.success? && response.body.to_s.include?('method type: post')
          response = HTTParty.get(
            endpoint,
            query: params,
            headers: { 'Accept' => 'application/json' }
          )
        end

        if !response.success? && params[:client_id].present?
          alt_response = HTTParty.post(
            endpoint,
            body: params.reject { |k, _| k.to_s == 'client_id' },
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
    end
  end
end
