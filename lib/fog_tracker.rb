require 'logger'

# Load all ruby files from the 'fog' and 'fog_tracker' directories
Dir[File.join(File.dirname(__FILE__), "fog_tracker/**/*.rb")].each {|f| require f}
Dir[File.join(File.dirname(__FILE__), "fog/**/*.rb")].each {|f| require f}

module FogTracker

  # The default polling interval in seconds
  # This. can be overriden when a FogTracker::Tracker is created, either
  # in the +accounts+ definitions, or in the +options+ parameter
  DEFAULT_POLLING_TIME = 300   # by default, poll all accounts every 5 minutes

  # Returns a slightly-modified version of the default Ruby Logger
  def self.default_logger(output = nil)
    logger = ::Logger.new(output)
    logger.sev_threshold = Logger::INFO
    logger.formatter = proc {|lvl, time, prog, msg|
      "#{lvl} #{time.strftime '%Y-%m-%d %H:%M:%S %Z'}: #{msg}\n"
    }
    logger
  end

  # Performs validation and cleanup on an Array of account Hashes.
  # Changes Strings to Symbols for all required keys.
  # @param [Hash] account_array an Array of Hash objects.
  # @return [Hash] the cleaned, validated Hash of account info.
  def self.validate_accounts(account_hash)
    account_hash.each do |name, account|
      account.symbolize_keys
      raise "Account #{name} defines no service" if not account[:service]
      raise "Account #{name} defines no provider" if not account[:provider]
      raise "Account #{name} defines no credentials" if not account[:credentials]
      if account[:exclude_resources]
        account[:exclude_resources] = account[:exclude_resources].map do |r|
          r.to_sym
        end
      end
    end
    account_hash
  end

end
