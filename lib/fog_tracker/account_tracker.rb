module FogTracker

  # Tracks all collections in a single Fog account
  class AccountTracker
    require 'fog'

    # The name (String) of the account this tracker is polling
    attr_reader :name
    # A Hash of account-specific configuration data
    attr_reader :account
    # A Logger-compatible object
    attr_reader :log
    # How long to wait between successive polling of this account (Integer)
    attr_reader :delay
    # The time that the *second-to-last* successful poll finished
    attr_reader :preceeding_update_time

    # Creates an object for tracking all collections in a single Fog account
    # @param [String] account_name a human-readable name for the account
    # @param [Hash] account a Hash of account configuration data
    # @param [Hash] options optional additional parameters:
    #  - :delay (Integer) - Default time between polling of accounts
    #  - :callback (Proc) - A Method or Proc to call each time an account is polled.
    #    (should take an Array of resources as its only required parameter)
    #  - :error_callback (Proc) - A Method or Proc to call if polling errors occur.
    #    (should take a single Exception as its only required parameter)
    #  - :logger - a Ruby Logger-compatible object
    def initialize(account_name, account, options={})
      @name     = account_name
      @account  = account
      @callback = options[:callback]
      @log      = options[:logger] || FogTracker.default_logger
      @delay    = options[:delay]  || account[:delay] ||
                              FogTracker::DEFAULT_POLLING_TIME
      @account[:delay] = @delay
      @error_proc = options[:error_callback]
      @log.debug "Creating tracker for account #{@name}."
      create_collection_trackers
    end

    # Starts a background thread, which periodically polls for all the
    # resource collections for this tracker's account
    def start
      if not running?
      @log.debug "Starting tracking for account #{@name}..."
        @timer = Thread.new do
          begin
            while true
              update ; sleep @delay
            end
          rescue Exception => e
            sleep @delay ; retry
          end
        end
      else
        @log.info "Already tracking account #{@name}"
      end
    end

    # Stops polling this tracker's account
    def stop
      if running?
        @log.info "Stopping tracker for #{@name}..."
        @timer.kill
        @timer = nil
      else
        @log.info "Tracking already stopped for account #{@name}"
      end
    end

    # Polls once for all the resource collections for this tracker's account
    def update
      begin
        @log.info "Polling account #{@name}..."
        @collection_trackers.each {|tracker| tracker.update}
        @preceeding_update_time = @most_recent_update
        @most_recent_update     = Time.now
        @log.info "Polled account #{@name}"
        @callback.call(all_resources) if @callback
      rescue Exception => e
        @log.error "Exception polling account #{name}: #{e.message}"
        e.backtrace.each {|line| @log.debug line}
        @error_proc.call(e) if @error_proc
        raise e
      end
    end

    # Returns true or false depending on whether this tracker is polling
    def running? ; @timer != nil end

    # Returns a Fog::Connection object to this account's Fog service
    def connection
      if ::Fog::const_defined? @account[:service]
        service_mod = ::Fog::const_get @account[:service]
        provider_class = service_mod.send(:const_get, @account[:provider])
        @fog_service ||= provider_class.new(@account[:credentials])
      else
        provider_mod = ::Fog::const_get @account[:provider]
        service_class = provider_mod.send(:const_get, @account[:service])
        @fog_service ||= service_class.new(@account[:credentials])
      end
    end

    # Returns an Array of resource types (Strings) to track
    def tracked_types
      types = connection.collections - (account[:exclude_resources] || [])
      types.map {|type| type.to_s}
    end

    # Returns an Array of all this Account's currently tracked Resources
    def all_resources
      (@collection_trackers.collect do |tracker|
        tracker.collection
      end).flatten
    end

    private

    # Creates and returns an Array of CollectionTracker objects -
    # one for each resource type associated with this account's service
    def create_collection_trackers
      @collection_trackers = tracked_types.map do |fog_collection_name|
        FogTracker::CollectionTracker.new(fog_collection_name.to_s, self)
      end
    end

  end
end
