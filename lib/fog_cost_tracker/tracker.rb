module FogCostTracker

  # Tracks one or more Fog accounts in an ActiveRecord database
  class Tracker
    require 'logger'

    # Creates an object for tracking Fog accounts
    #
    # ==== Attributes
    #
    # * +accounts+ - a Hash of account information (see accounts.yml.example)
    # * +options+ - Hash of optional parameters
    #
    # ==== Options
    #
    # * +:delay+ - Default time between polling of accounts
    # * +:log+ - a Ruby Logger-compatible object
    def initialize(accounts = {}, options={})
      @accounts = accounts
      @log      = options[:logger]
      @delay    = options[:delay]
      # Create a Hash that maps account names to AccountTrackers
      @trackers = create_trackers(accounts)
    end

    # Returns a Hash of AccountTracker objects, indexed by account name
    #
    # ==== Attributes
    #
    # * +accounts+ - a Hash of account information (see accounts.yml.example)
    def create_trackers(accounts)
      accounts.each do |name, account|
        @log.debug "Setting up tracker for account #{name}"
        @accounts[name] = AccountTracker.new(
          name, account, {:delay => @delay, :logger => @log}
        )
      end
    end

    # Invokes the start method on all the @trackers
    def start
      if not running?
        @log.info "Tracking #{@trackers.keys.count} accounts..."
        @accounts.each_value {|tracker| tracker.start}
        @running = true
      else
        @log.info "Already tracking #{@trackers.keys.count} accounts"
      end
    end

    # Invokes the stop method on all the @trackers
    def stop
      if running?
        @log.info "Stopping tracker..."
        @running = false
      else
        @log.info "Tracking already stopped"
      end
    end

    # Returns true or false/nil depending on whether this tracker is polling
    def running? ; @running end

  end
end
