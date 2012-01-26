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
      @collection = @account_tracker.connection.send(@type)
      @log.info "Discovered #{@collection.count} #{@type} on #{@account_name}."
    end

  end
end
