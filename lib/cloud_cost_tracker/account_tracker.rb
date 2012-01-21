module CloudCostTracker

  # Tracks a single Fog account in an ActiveRecord database
  class AccountTracker
    require 'fog'

    attr_reader :name, :account, :log, :delay

    # Creates an object for tracking a single Fog account
    #
    # ==== Attributes
    #
    # * +account_name+ - a human-readable name for the account (String)
    # * +account+ - a Hash of account information (see accounts.yml.example)
    # * +options+ - Hash of optional parameters
    #
    # ==== Options
    #
    # * +:delay+ - Default time between polling of accounts
    # * +:log+ - a Ruby Logger-compatible object
    def initialize(account_name, account, options={})
      @name     = account_name
      @account  = account
      @log      = options[:logger] || CloudCostTracker.default_logger
      @delay    = options[:delay]  || account[:polling_time] ||
                              CloudCostTracker::DEFAULT_POLLING_TIME
      @log.debug "Creating tracker for account #{@name}."
      create_resource_trackers
    end

    # Starts a background thread, which updates all @resource_trackers
    def start
      if not running?
      @log.debug "Starting tracking for account #{@name}..."
        @timer = Thread.new do
          while true do
            @log.info "Polling account #{@name}..."
            @resource_trackers.each {|tracker| tracker.update}
            sleep @delay
          end
        end
      else
        @log.info "Already tracking account #{@name}"
      end
    end

    # Stops all the @resource_trackers
    def stop
      if running?
        @log.info "Stopping tracker for #{name}..."
        @timer.kill
        @timer = nil
      else
        @log.info "Tracking already stopped for account #{@name}"
      end
    end

    # Returns true or false depending on whether this tracker is polling
    def running? ; @timer != nil end

    # Returns a Fog::Connection object to this account's Fog service
    def connection
      service_mod = ::Fog::const_get @account[:service]
      provider_class = service_mod.send(:const_get, @account[:provider])
      @fog_service ||= provider_class.new(@account[:credentials])
    end

    private

    # Creates and returns an Array of ResourceTracker objects -
    # one for each resource type associated with this account's service
    def create_resource_trackers
      @resource_trackers = Array.new
      connection.collections.each do |fog_collection_name|
        # only create a ResourceTracker if its BillingPolicy class exists
        if CloudCostTracker.get_billing_policy_class(
          @account[:service], @account[:provider], fog_collection_name
        )
          @resource_trackers <<
            CloudCostTracker::ResourceTracker.new(fog_collection_name.to_s, self)
        end
      end
      @resource_trackers
    end

  end
end
