module FogTracker
  module Extensions
    # Adds convenience methods to Fog::Model instances for gathering
    # information about its account, and about other Fog::Model resources
    module FogModel

      # a FogTracker::CollectionTracker - *do not modify* - used for {#tracker_account}
      attr_accessor :_fog_collection_tracker

      # a FogTracker::QueryParser - *do not modify* - used for tracker_query
      attr_accessor :_query_processor

      # Returns a cleaned copy of the resource's account information
      # from the its collection tracker (credentials are removed).
      # @return [Hash] a cleaned copy of the resource's account information
      def tracker_account
        (not _fog_collection_tracker) ? Hash.new :
        _fog_collection_tracker.clean_account_data
      end

      # Returns Fog::Model resources from this Resource's account only.
      # @param [String] collection_name a String which is converted to
      #   a RegEx, and used to match collection names for resources
      #   in the same account as the current resource.
      # @return [Array <Fog::Model>] an Array of resources from this Model's
      #   accout, whose collection matches collection_name.
      def account_resources(collection_name)
        results = Array.new
        if @_query_processor
          results = @_query_processor.execute(
            "#{tracker_account[:name]}::"+
            "#{tracker_account[:service]}::"+
            "#{tracker_account[:provider]}::"+
            "#{collection_name}"
          )
          (results.each {|r| yield r}) if block_given?
        end
        results
      end

      # Runs a query across all accounts using a 
      # {FogTracker::Query::QueryProcessor}. Any code block parameter will
      # be executed once for (and with) each resulting resource.
      # @param [String] query a string used to filter for matching resources
      # @return [Array <Fog::Model>] an Array of Resources, filtered by query
      def tracker_query(query_string)
        results = Array.new
        if @_query_processor
          results = @_query_processor.execute(query_string)
          (results.each {|r| yield r}) if block_given?
        end
        results
      end

    end
  end
end

module Fog
  class Model
    include FogTracker::Extensions::FogModel
  end
end
