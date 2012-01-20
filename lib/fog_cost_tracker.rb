require 'active_record'
require 'logger'

# Load all ruby files from 'fog_cost_tracker' directory
Dir[File.join(File.dirname(__FILE__), "fog_cost_tracker/**/*.rb")].each {|f| require f}

module FogCostTracker

  DEFAULT_POLLING_TIME = 300   # by default, poll all accounts every 5 minutes

  # Returns a slightly-modified version of the default Ruby Logger
  def self.default_logger
    logger = ::Logger.new(STDOUT)
    logger.sev_threshold = Logger::INFO
    logger.formatter = proc {|lvl, time, prog, msg|
      "#{lvl} #{time.strftime '%Y-%m-%d %H:%M:%S %Z'}: #{msg}\n"
    }
    logger
  end

  # Returns an Array of Fog Classes associated with the
  # given provider and service
  def self.resources_for_service(provider_name, service_name)
    resources = {
      "AWS" => {
        "Compute" => [
            'server', 'snapshot', 'volume'
          ]
      }
    }
    resources[provider_name][service_name]
  end

end
