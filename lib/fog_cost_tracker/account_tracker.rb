module FogCostTracker

  # Tracks a single Fog account in an ActiveRecord database
  class AccountTracker
    require 'logger'

    attr_reader :name, :account, :log

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
      @log      = options[:logger] || FogCostTracker.default_logger
      @delay    = options[:delay]  || account[:polling_time] ||
                              FogCostTracker::DEFAULT_POLLING_TIME
      @log.debug "Created tracker for account #{@name}."
      create_resource_trackers
    end

    # Creates and returns an Array of ResourceTracker objects -
    # one for each resource type associated with this account's service
    def create_resource_trackers
      @resource_trackers = []
      FogCostTracker.resources_for_service(
      @account[:provider], @account[:service]).each do |type|
        @resource_trackers << FogCostTracker::ResourceTracker.new(self, type)
      end
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

    # Invokes the stop method on all the @trackers
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

  end
end
