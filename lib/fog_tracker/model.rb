# add an accessor and a method to decorate Fog::Model instances
# with tracker account information
module Fog
  class Model

    # a FogTracker::CollectionTracker
    attr_accessor :fog_collection_tracker

    # returns a clean copy of the resource's account information
    # from the its collection tracker
    def tracker_account
      if fog_collection_tracker
        fog_collection_tracker.clean_account_data
      else
        Hash.new
      end
    end

  end
end
