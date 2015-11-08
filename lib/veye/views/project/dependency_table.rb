require_relative '../base_table.rb'

module Veye
  module Project
    class DependencyTable < BaseTable
      def initialize
        headings = %w{index name prod_key version_current version_requested outdated stable license}
        super("Project dependencies", headings)
      end
      def format(results, filename = nil)
        results = [results] if results.is_a?(Hash)

        results.each_with_index do |result, index|
          row = [
            index + 1,
            (filename or result["name"]),
            result["prod_key"],
            result["version_current"],
            result["version_requested"],
            result["outdated"] ? "outdated":"no",
            result["stable"] ? "stable": "unstable",
            result["licenses"].to_a.map {|x| x['name']}.join(',')
          ]
          @table << row
        end
      end
    end
  end
end
