require_relative 'profile_csv.rb'
require_relative 'profile_json.rb'
require_relative 'profile_pretty.rb'
require_relative 'profile_table.rb'

require_relative 'favorite_csv.rb'
require_relative 'favorite_json.rb'
require_relative 'favorite_pretty.rb'
require_relative 'favorite_table.rb'

module Veye
  module User
    class Me
      @@profile_formats = {
        'csv'     => ProfileCSV.new,
        'json'    => ProfileJSON.new,
        'pretty'  => ProfilePretty.new,
        'table'   => ProfileTable.new
      }

      @@favorite_formats = {
        'csv'     => FavoriteCSV.new,
        'json'    => FavoriteJSON.new,
        'pretty'  => FavoritePretty.new,
        'table'   => FavoriteTable.new
      }

      def self.get_profile(api_key)
        user_api = API::Resource.new(RESOURCE_PATH)
        response_data = nil
        qparams = {:params => {:api_key => api_key}}

        user_api.resource.get(qparams) do |response, request, result|
          response_data = API::JSONResponse.new(request, result, response)
        end

        return response_data
      end

      def self.get_favorites(api_key)
        user_api = API::Resource.new(RESOURCE_PATH)
        response_data = nil
        qparams = {:params => {:api_key => api_key}}

        user_api.resource['/favorites'].get(qparams) do |response, request, result|
          response_data = API::JSONResponse.new(request, result, response)
        end

        return response_data
      end

      def self.format_profile(results, format = 'pretty')
        formatter = @@profile_formats[format]
        formatter.before
        formatter.format(results)
        formatter.after
      end

      def self.format_favorites(results, format = 'pretty')
        formatter = @@favorite_formats[format]
        
        formatter.before
        formatter.format results
        formatter.after
      end

    end
  end
end

