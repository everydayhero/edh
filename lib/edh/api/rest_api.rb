module EDH
  module Passport
    REST_SERVER = "https://passport.everydayhero.com/api/v1"

    # Methods used to interact with Passport's REST API.  

    module RestAPIMethods
      #convenience methods
      def create pp_method, args = {}, options = {}
        rest_call("me/#{pp_method}", args, options, :post)
      end

      def delete pp_action_uid, args = {}, options = {}
        rest_call("actions/#{pp_action_uid}", args, options, :delete)
      end

      def update pp_action_uid, args = {}, options = {}
        rest_call("actions/#{pp_action_uid}", args, options, :put)
      end

      # Make a call to the REST API. 
      #
      # @note The order of the last two arguments is non-standard (for historical reasons).  Sorry.
      # 
      # @param pp_method the API call you want to make
      # 
      # @raise [EDH::Passport::APIError] if Passport returns an error
      # 
      # @return the result from Passport
      def rest_call(pp_method, args = {}, options = {}, verb = "get")
        args = MultiJson.load(args) if args.is_a?(String)
        api("#{pp_method}", args.merge('format' => 'json'), verb, options) do |response|
          # check for REST API-specific errors
          if response.status >= 400
            begin
              response_hash = MultiJson.load(response.body)
            rescue MultiJson::DecodeError
              response_hash = {}
            end

            error_info = {
              'code' => response_hash['error_code'],
              'error_subcode' => response_hash['error_subcode'],
              'message' => response_hash['error_msg']
            }

            if response.status >= 400
              raise ClientError.new(response.status, response.body, error_info)
            end
          end
        end
      end
    end

  end # module Passport
end # module EDH
