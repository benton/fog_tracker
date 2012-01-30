module FogTracker
  module Extensions
    # Adds convenience methods to Fog::Model instances for gathering
    # information about its account, and about other resources
    module FogModel
      extend Forwardable        # Resources need to be queriable
      
      # a FogTracker::CollectionTracker -
      #    *do not modify - used for {#tracker_account}
      attr_accessor :_fog_collection_tracker

      # a FogTracker::QueryParser -
      #    *do not modify - used for {#tracker_query}
      attr_accessor :_query_processor
      def_delegator :@_query_processor, :execute, :tracker_query

      # Returns a cleaned copy of the resource's account information
      # from the its collection tracker (credentials are removed).
      def tracker_account
        (not _fog_collection_tracker) ? Hash.new :
        _fog_collection_tracker.clean_account_data
      end

      # Returns Fog::Model resources from this Resource's account only
      # @param [String] collection_name -the name of a resource collection
      #      in the same account as this resource
      def account_resources(collection_name)
        (not @_query_processor) ? Array.new :
        @_query_processor.execute(
        "#{tracker_account[:name]}::"+
        "#{tracker_account[:service]}::"+
        "#{tracker_account[:provider]}::"+
        "#{collection_name}"
        )
      end
    end
  end
end

module Fog
  class Model
    include FogTracker::Extensions::FogModel
  end
end 
