module FogCostTracker

  # Tracks one or more AwsAccounts in an ActiveRecord database
  class Tracker
    require 'logger'

    attr_accessor :delay  # How many seconds to wait between status updates
    attr_reader   :log    # a Ruby Logger-compatible object
    attr_reader   :supported_resources  # maps service tags to resrouce names

    # Creates an object for tracking AWS accounts
    # Tracked info is stored in an ActiveRecord database with config db_config
    def initialize(options={})
      @log   = options[:logger] || FogCostTracker.default_logger
      @delay = options[:delay]  || 300 # default delay is 5 minutes
      establish_connections
    end

    def establish_connections
      conf_file = File.join(File.dirname(__FILE__),
        "../../config/supported_resources.yml")
      @supported_resources = YAML.load File.read conf_file
      @supported_resources.keys.each do |svc_tag|
        @log.info "Connecting to #{svc_tag}..."
        #@services[svc_tag] =
      end
    end

    def services
      @supported_resources.keys
    end

    def running?
      @timer != nil
    end

    def start
      if not running?
        @timer = Thread.new do
          while true do
            services.each do |svc_tag|
              @supported_resources[svc_tag].each do |resource_name|
                @log.info "Fetching #{resource_name} from #{svc_tag}..."
              end
            end
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
