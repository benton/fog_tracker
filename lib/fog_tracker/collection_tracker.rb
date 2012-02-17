module FogTracker

  # Tracks a single Fog collection in a single account.
  # Each {CollectionTracker} instance is tightly bound to an {AccountTracker}.
  class CollectionTracker

    # An Array of Fog::Model objects, all of the same resource type (class)
    attr_reader :collection

    # Creates an object for tracking a single Fog collection in a single account
    # @param [String] resource_type the Fog collection name for this resource type
    # @param [AccountTracker] account_tracker the AccountTracker for this tracker's
    #       account. Usually the AccountTracker that created this object
    def initialize(resource_type, account_tracker)
      @type             = resource_type
      @account_tracker  = account_tracker
      @account          = account_tracker.account
      @account_name     = account_tracker.name
      @log              = account_tracker.log
      @collection       = Array.new
      @log.debug "Created tracker for #{@type} on #{@account_name}."
    end

    # Polls the {AccountTracker}'s connection for updated info on all existing
    # instances of this tracker's resource_type
    def update
      new_collection = Array.new
      fog_collection = @account_tracker.connection.send(@type) || Array.new
      @log.info "Fetching #{fog_collection.count} #{@type} on #{@account_name}."
      # Here's where most of the network overhead is actually incurred
      fog_collection.each do |resource|
        @log.debug "Fetching resource: #{resource.class} #{resource.identity}"
        resource._fog_collection_tracker = self
        new_collection << resource
        #@log.debug "Got resource: #{resource.inspect}"
      end
      @log.info "Fetched #{new_collection.count} #{@type} on #{@account_name}."
      @collection = new_collection
    end

    # @return [Hash] a Hash of account information, slighly modified:
    #    a :name parameter is added, and the :credentials are removed
    #    :last_polling_time is also added
    def clean_account_data
      @clean_data ||= @account  # generate this data only once per res
      @clean_data[:name] = @account_name
      @clean_data[:credentials] = Hash.new
      @clean_data[:last_polling_time] = @account_tracker.last_polling_time
      @clean_data
    end

  end
end
