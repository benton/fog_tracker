require 'active_record'
require 'logger'

# Load all ruby files from 'fog_cost_tracker' directory
Dir[File.join(File.dirname(__FILE__), "fog_cost_tracker/**/*.rb")].each {|f| require f}

module FogCostTracker
  # Returns a slightly-modified version of the default Ruby Logger
  def self.default_logger
    logger = ::Logger.new(STDOUT)
    logger.sev_threshold = Logger::INFO
    logger.formatter = proc {|lvl, time, prog, msg|
      "#{lvl} #{time.strftime '%Y-%m-%d %H:%M:%S %Z'}: #{msg}\n"
    }
    logger
  end
end
