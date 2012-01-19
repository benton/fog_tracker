module FogCostTracker

  # Tracks one or more AwsAccounts in an ActiveRecord database
  class Tracker
    require 'logger'

    attr_accessor :delay  # How many seconds to wait between status updates
    attr_reader   :services, :log
    
    # Creates an object for tracking AWS accounts
    # Tracked info is stored in an ActiveRecord database with config db_config
    def initialize(options={})
      @log   = options[:logger] || AWSTracker.default_logger
      @delay = options[:delay]  || 300 # default delay is 5 minutes
      discover_fog_services
    end

    def discover_fog_services
      @log.info "Enumerating Fog services..."
      @services = []
    end

    def running?
      @timer != nil
    end

    def start
      if not running?
        @log.info "Tracking #{services.count} services..."
        @timer = Thread.new do
          while true do
            @log.info "Polling #{services.count} services..."
            sleep @delay
          end
        end
      else
        @log.info "Already tracking #{services.count} services"
      end
    end

    def stop
      if running?
        @log.info "Stopping tracker..."
        @timer.kill
        @timer = nil
      else
        @log.info "Tracking already stopped"
      end
    end

  end  
end
