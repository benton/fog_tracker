module FogCostTracker

  # Tracks a single Fog Resource type for a single Account
  class ResourceTracker
    require 'logger'

    # Creates an object for tracking a single Fog account
    #
    # ==== Attributes
    #
    # * +resource_type+ -
    # * +account_tracker+ - a human-readable name for the account (String)
    def initialize(resource_type, account_tracker)
      @account_name   = account_tracker.name
      @account        = account_tracker.account
      @log            = account_tracker.log
      @type           = resource_type
      @connection     = account_tracker.connection
      @log.debug "Created tracker for #{@type} on #{@account_name}."
    end

    # Polls the account's connection for updated info on all existing
    # instances of the relevant resource type
    def update
      @log.info "Polling for resource #{@type} on #{@account_name}..."
    end

  end
end
