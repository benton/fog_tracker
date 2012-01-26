module FogTracker

  # Tracks one or more Fog accounts and exposes a query() on the results
  class Tracker

    attr_accessor :accounts

    # Creates an object for tracking Fog accounts
    #
    # ==== Attributes
    #
    # * +accounts+ - a Hash of account information (see accounts.yml.example)
    # * +options+ - Hash of optional parameters
    #
    # ==== Options
    #
    # * +:delay+ - Time between polling of accounts. Overrides per-account value
    # * +:callback+ - A Proc to call each time an account is polled.
    #     It should take the name of the account as its only required parameter
    # * +:logger+ - a Ruby Logger-compatible object
    def initialize(accounts = {}, options = {})
      @accounts = accounts
      @delay    = options[:delay]
      @callback = options[:callback]
      @log      = options[:logger] || FogTracker.default_logger
      # Create a Hash that maps account names to AccountTrackers
      create_trackers
    end

    # Invokes the start method on all the @trackers
    def start
      if not running?
        @log.info "Tracking #{@trackers.keys.count} accounts..."
        @trackers.each_value {|tracker| tracker.start}
        @running = true
      else
        @log.info "Already tracking #{@trackers.keys.count} accounts"
      end
    end

    # Invokes the stop method on all the @trackers
    def stop
      if running?
        @log.info "Stopping tracker..."
        @trackers.each_value {|tracker| tracker.stop}
        @running = false
      else
        @log.info "Tracking already stopped"
      end
    end

    # Returns true or false/nil depending on whether this tracker is polling
    def running? ; @running end

    # Returns an array of Resource types (Strings) for a given account
    def types_for_account(account_name)
      @trackers[account_name].tracked_types
    end

    # Returns an array of Resources matching the +query_string+
    # Calls any block passed for each resulting resource
    #
    # ==== Attributes
    #
    # * +query_string+ - a String used to filter the discovered Resources
    #          it might look like: "Account Name::Compute::AWS::servers"
    def query(query_string)
      results = FogTracker::Query::QueryProcessor.new(
        @trackers, :logger => @log
      ).execute(query_string)
      (results.each {|r| yield r}) if block_given?
      results
    end
    alias :[] :query

    # Returns this tracker's logger, for changing logging dynamically
    def logger
      @log
    end

    private

    # Creates a Hash of AccountTracker objects, indexed by account name
    def create_trackers
      @trackers = Hash.new
      @accounts.each do |name, account|
        @log.debug "Setting up tracker for account #{name}"
        @trackers[name] = AccountTracker.new(name, account,
        {:delay => @delay, :callback => @callback, :logger => @log})
      end
    end

  end
end
