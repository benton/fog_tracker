module FogTracker

  # Tracks a single Fog collection in a single account
  class ResourceTracker

    attr_accessor :collection

    # Creates an object for tracking a single Fog collection in a single account
    #
    # ==== Attributes
    #
    # * +resource_type+ - the Fog collection name (String) for this resource type
    # * +account_tracker+ - the AccountTracker for this tracker's @collection
    def initialize(resource_type, account_tracker)
      @type             = resource_type
      @account_tracker  = account_tracker
      @account          = account_tracker.account
      @account_name     = account_tracker.name
      @log              = account_tracker.log
      @collection       = Array.new
      @log.debug "Created tracker for #{@type} on #{@account_name}."
    end

    # Polls the account's connection for updated info on all existing
    # instances of the relevant resource type, and saves them as @collection
    def update
      @log.info "Polling #{@type} on #{@account_name}..."
      fog_collection = @account_tracker.connection.send(@type) || Array.new
      @log.info "Fetching #{fog_collection.count} #{@type} on #{@account_name}."
      new_collection = Array.new
      # Here's where most of the network overhead is actually incurred
      fog_collection.each do |resource|
        @log.debug "Fetching resource: #{resource.class} #{resource.identity}"
        resource.fog_collection_tracker = self
        new_collection << resource
        @log.debug "Got resource: #{resource.inspect}"
      end
      @collection = new_collection
    end

    # Returns a Hash of account information as resource.tracker_account
    # a :name parameter is added, and the :credentials are removed
    def clean_account_data
      @clean_data ||= @account  # generate this data only once per res
      @clean_data[:name] = @account_name
      @clean_data[:credentials] = Hash.new
      @clean_data
    end

  end
end
