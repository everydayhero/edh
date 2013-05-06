module Koala
  module Passport
    REST_SERVER = "passport.everydayhero.com/api/v1"

    # Methods used to interact with Passport's REST API.  

    module RestAPIMethods
      # Set a Passport application's properties.
      # 
      # @param properties a hash of properties you want to update with their new values.
      # @param (see #rest_call)
      # @param options (see #rest_call)
      #
      # @return true if successful, false if not.  (This call currently doesn't give useful feedback on failure.)
      def set_app_properties(properties, args = {}, options = {})
        raise AuthenticationError.new(nil, nil, "setAppProperties requires an access token") unless @access_token
        rest_call("admin.setAppProperties", args.merge(:properties => MultiJson.dump(properties)), options, "post")
      end

      # Make a call to the REST API. 
      #
      # @note The order of the last two arguments is non-standard (for historical reasons).  Sorry.
      # 
      # @param pp_method the API call you want to make
      # @param args (see Koala::Passport::GraphAPIMethods#graph_call)
      # @param options (see Koala::Passport::GraphAPIMethods#graph_call)
      # @param verb (see Koala::Passport::GraphAPIMethods#graph_call)
      # 
      # @raise [Koala::Passport::APIError] if Passport returns an error
      # 
      # @return the result from Passport
      def rest_call(pp_method, args = {}, options = {}, verb = "get")
        api("method/#{pp_method}", args.merge('format' => 'json'), verb, options) do |response|
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

            if response.status >= 500
              raise ServerError.new(response.status, response.body, error_info)
            else
              raise ClientError.new(response.status, response.body, error_info)
            end
          end
        end
      end
    end

  end # module Passport
end # module Koala
