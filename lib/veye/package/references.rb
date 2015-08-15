require 'gli'
require_relative '../views/package.rb'
require_relative '../base_executor.rb'

module Veye
  module Package
    module API
    end

    class References < BaseExecutor
      @@output_formats = {
        'csv'       => Package::ReferencesCSV.new,
        'json'      => Package::ReferencesJSON.new,
        'pretty'    => Package::ReferencesPretty.new,
        'table'     => Package::ReferencesTable.new
      }

      def self.get_references(package_key, options = {})
        prod_key,lang = Package.parse_key(package_key)
        results = Veye::API::Package.get_references(prod_key, lang, options[:page])
        if valid_response?(results, "No references for: `#{package_key}`")
          show_results(@@output_formats, results.data, options, results.data['paging'])
        end
      end
    end
  end
end
