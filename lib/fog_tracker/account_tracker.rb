module FogTracker

  # Tracks a single Fog account in an ActiveRecord database
  class AccountTracker
    require 'fog'

    attr_reader :name, :account, :log, :delay
    attr_reader :resource_trackers

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
    # * +:callback+ - A Method or Proc to call each time an account is polled.
    #     It should take the name of the account as its only required parameter
    # * +:logger+ - a Ruby Logger-compatible object
    def initialize(account_name, account, options={})
      @name     = account_name
      @account  = account
      @callback = options[:callback]
      @log      = options[:logger] || FogTracker.default_logger
      @delay    = options[:delay]  || account[:polling_time] ||
                              FogTracker::DEFAULT_POLLING_TIME
      @log.debug "Creating tracker for account #{@name}."
      create_resource_trackers
    end

    # Starts a background thread, which updates all @resource_trackers
    def start
      if not running?
      @log.debug "Starting tracking for account #{@name}..."
        @timer = Thread.new do
          begin
            while true do
              @log.info "Polling account #{@name}..."
              @resource_trackers.each {|tracker| tracker.update}
              @callback.call @name if @callback
              sleep @delay
            end
          rescue Exception => e
            @log.error "Exception polling account #{name}: #{e.message}"
            @log.error e.backtrace.join("\n")
            exit 99
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

    # Returns an Array of resource types (Strings) to track
    def tracked_types
      connection.collections.delete_if do |resource_type|
        account[:exclude_resources] &&
          account[:exclude_resources].include? resource_type
      end
    end

    private

    # Creates and returns an Array of ResourceTracker objects -
    # one for each resource type associated with this account's service
    def create_resource_trackers
      @resource_trackers = tracked_types.map do |fog_collection_name|
        FogTracker::ResourceTracker.new(fog_collection_name.to_s, self)
      end
    end

  end
end
