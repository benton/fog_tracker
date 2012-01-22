module FogTracker

  # Tracks a single Fog Resource type for a single Account
  class ResourceTracker

    # Creates an object for tracking a single Fog account
    #
    # ==== Attributes
    #
    # * +resource_type+ -
    # * +account_tracker+ - a human-readable name for the account (String)
    def initialize(resource_type, account_tracker)
      @type             = resource_type
      @account_tracker  = account_tracker
      @account          = account_tracker.account
      @account_name     = account_tracker.name
      @log              = account_tracker.log
      @log.debug "Created tracker for #{@type} on #{@account_name}."
    end

    # Polls the account's connection for updated info on all existing
    # instances of the relevant resource type
    def update
      @log.info "Polling #{@type} on #{@account_name}..."
      @collection = @account_tracker.connection.send(@type)
      @log.info "Discovered #{@collection.count} #{@type} on #{@account_name}."
    end

  end
end
