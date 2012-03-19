module FogTracker

  # Tracks one or more Fog accounts and exposes a {#query} on the results
  class Tracker

    #a Hash of account information (see accounts.yml.example)
    attr_reader :accounts

    # Creates an object for tracking multiple Fog accounts
    # @param [Hash] accounts a Hash of account information
    #    (see accounts.yml.example)
    # @param [Hash] options optional additional parameters:
    #  - :delay (Integer) - Default time between polling of accounts
    #  - :callback (Proc) - A Method or Proc to call each time an account is polled.
    #    (should take an Array of resources as its only required parameter)
    #  - :error_callback (Proc) - A Method or Proc to call if polling errors occur.
    #    (should take a single Exception as its only required parameter)
    #  - :logger - a Ruby Logger-compatible object
    def initialize(accounts = {}, options = {})
      @delay      = options[:delay]
      @callback   = options[:callback]
      @log        = options[:logger] || FogTracker.default_logger
      @error_proc = options[:error_callback]
      @running    = false
      self.accounts= accounts
      # Create a Hash that maps account names to AccountTrackers
      create_trackers
    end

    # Starts periodically polling all this tracker's accounts
    # for all their Fog resource collections
    def start
      if not running?
        @log.info "Tracking #{@trackers.keys.count} accounts..."
        @trackers.each_value {|tracker| tracker.start}
        @running = true
      else
        @log.info "Already tracking #{@trackers.keys.count} accounts"
      end
    end

    # Stops polling for all this tracker's accounts
    def stop
      if running?
        @log.info "Stopping tracker..."
        @trackers.each_value {|tracker| tracker.stop}
        @running = false
      else
        @log.info "Tracking already stopped"
      end
    end

    # Polls all accounts once in the calling thread (synchronously)
    # @return [Array <Fog::Model>] an Array of all discovered resources
    def update
      @trackers.each_value {|tracker| tracker.update}
      results = all
      (results.each {|r| yield r}) if block_given?
      results
    end

    # Returns true or false, depending on whether this tracker is polling
    # @return [true, false]
    def running? ; @running end

    # Returns an Array of resource types for a given account
    # @param [String] name the name of the account
    # @return [Array<String>] an array of Resource types
    def types_for_account(account_name)
      @trackers[account_name].tracked_types
    end

    # Returns an array of Resources matching the query_string.
    # Calls any block passed for each resulting resource.
    # @param [String] query_string a string used to filter for matching resources
    #          it might look like: "Account Name::Compute::AWS::servers"
    # @return [Array <Fog::Model>] an Array of Resources, filtered by query
    def query(query_string)
      results = FogTracker::Query::QueryProcessor.new(
        @trackers, :logger => @log
      ).execute(query_string)
      (results.each {|r| yield r}) if block_given?
      results
    end
    alias :[] :query

    # Returns an Array of all Resources currenty tracked
    # @return [Array <Fog::Model>] an Array of Resources
    def all
      results = query '*::*::*::*'
      (results.each {|r| yield r}) if block_given?
      results
    end

    # Returns the time of given account's most recent successful update
    # @param [String] account_name the name of the account that was polled
    # @return [Time] the time the account finished updating
    def preceeding_update_time(account_name)
      @trackers[account_name].preceeding_update_time
    end

    # Returns this tracker's logger, for changing logging dynamically
    def logger ; @log end

    # Sets the account information.
    # If any account info has changed, all trackers are restarted.
    # @param [Hash] accounts a Hash of account information
    #    (see accounts.yml.example)
    def accounts=(new_accounts)
      old_accounts = @accounts
      @accounts = FogTracker.validate_accounts(new_accounts)
      if (@accounts != old_accounts)
        stop if (was_running = running?)
        create_trackers
        start if was_running
      end
      @accounts
    end

    private

    # Creates a Hash of AccountTracker objects, indexed by account name
    def create_trackers
      @trackers = Hash.new
      @accounts.each do |name, account|
        @log.debug "Setting up tracker for account #{name}"
        @trackers[name] = AccountTracker.new(name, account, {
            :delay => @delay, :error_callback => @error_proc, :logger => @log,
            :callback => Proc.new do |resources|
              # attach a QueryProcessor to all returned resources
              qp = FogTracker::Query::QueryProcessor.new(@trackers, :logger => @log)
              resources.each {|resource| resource._query_processor = qp}
              # now relay the resources back to the client software
              @callback.call(resources) if @callback
            end
          }
        )
      end
    end

  end
end
