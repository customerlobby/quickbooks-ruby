module Quickbooks
  module Service
    class Reconnect

      attr_reader :error_message
      attr_reader :error_code
      attr_reader :server_time
      attr_reader :oauth_token
      attr_reader :oauth_secret

      HTTP_CONTENT_TYPE    = 'application/xml'
      HTTP_ACCEPT          = 'application/xml'
      HTTP_ACCEPT_ENCODING = 'gzip, deflate'

      def initialize(oauth)
        @oauth = oauth
        @uri   = 'https://appcenter.intuit.com/api/v1/connection/reconnect'
      end

      def access_token=(token)
        @oauth = token
      end

      def refresh_tokens
        parse_response(do_http(:get, @uri, {}, {}))
      end

      private

      def parse_response(response)
        xmldoc = Nokogiri::XML(response.plain_body)

        @error_message = xmldoc.at_xpath("//xmlns:ReconnectResponse//xmlns:ErrorMessage").content
        @error_code    = xmldoc.at_xpath("//xmlns:ReconnectResponse//xmlns:ErrorCode").content
        @server_time   = xmldoc.at_xpath("//xmlns:ReconnectResponse//xmlns:ServerTime").content
        if @error_code == '0'
          @oauth_token  = xmldoc.at_xpath("//xmlns:ReconnectResponse//xmlns:OAuthToken").content
          @oauth_secret = xmldoc.at_xpath("//xmlns:ReconnectResponse//xmlns:OAuthTokenSecret").content
        end

      rescue => e
        raise "Exception parsing response: #{e}, Response: #{response.plain_body}"
      end

      def do_http(method, url, body, headers) # throws IntuitRequestException
        if @oauth.nil?
          raise "OAuth client has not been initialized. Initialize with setter access_token="
        end
        unless headers.has_key?('Content-Type')
          headers['Content-Type'] = HTTP_CONTENT_TYPE
        end
        unless headers.has_key?('Accept')
          headers['Accept'] = HTTP_ACCEPT
        end
        unless headers.has_key?('Accept-Encoding')
          headers['Accept-Encoding'] = HTTP_ACCEPT_ENCODING
        end

        response = @oauth.get(url, headers)
        check_response(response)
      end

      def check_response(response)
        status = response.code.to_i
        case status
          when 200
            response
          when 302
            raise 'Unhandled HTTP Redirect'
          when 401
            raise Quickbooks::AuthorizationFailure
          else
            raise "HTTP Error Code: #{status}, Msg: #{response.plain_body}"
        end
      end

    end
  end
end
