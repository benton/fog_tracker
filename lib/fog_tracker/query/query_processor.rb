module FogTracker
  module Query
    class QueryProcessor
      # Creates an object for filtering Resources from a set of AccountTrackers
      #
      # ==== Attributes
      #
      # * +trackers+ - a Hash of AccountTrackers, indexed by Account name
      # * +options+ - Hash of optional parameters
      #
      # ==== Options
      #
      # * +:logger+ - a Ruby Logger-compatible object
      def initialize(trackers, options={})
        @trackers = trackers
        @log      = options[:logger] || FogTracker.default_logger
      end

      # Returns an Array of Resources, filtered by +query+
      def execute(query)
        results = Array.new
        @trackers.each do |account_name, account_tracker|
          account_tracker.resource_trackers.each do |resource_tracker|
            resource_tracker.collection.each do |resource|
              results << resource
            end
          end
        end
        results
      end

    end
  end
end