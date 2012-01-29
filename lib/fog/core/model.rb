module Fog

  # Adds an accessor and a method to decorate Fog::Model instances
  # with tracker account information
  class Model

    # a FogTracker::CollectionTracker
    attr_accessor :_fog_collection_tracker

    # Returns a cleaned copy of the resource's account information
    # from the its collection tracker (credentials are removed).
    def tracker_account
      if _fog_collection_tracker
        _fog_collection_tracker.clean_account_data
      else
        Hash.new
      end
    end

  end
end
