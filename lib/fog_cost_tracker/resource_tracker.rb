module FogCostTracker

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
      generate_billing_records
    end

    # Returns an Array of BillingRecords for the current @collection
    def generate_billing_records
      @collection.map do |resource|
        duration = get_duration_for_resource(resource)
        @log.debug "Computing cost for #{resource.id} over #{duration} seconds"
        total = billing_policy.get_cost_for_time(resource, duration)
        @log.debug "Charging #{total} for #{duration} seconds of #{resource.id}"
      end
    end

    # Returns the duration for a billing record for a +resource+
    # For now, just returns the Tracker delay
    # TODO: return the time since +resource+'s last BillingRecord
    def get_duration_for_resource(resource)
      @account_tracker.delay
    end

    # Creates (as needed) and returns a BillingPolicy object for this resource
    def billing_policy
      @policy ||= FogCostTracker.get_billing_policy_class(
        @account[:service], @account[:provider], @type).new
    end
  end
end
