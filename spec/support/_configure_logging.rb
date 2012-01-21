# Setup a global Logger for all tests
LOG_LEVEL = ::Logger::WARN
LOG = FogCostTracker.default_logger
LOG.info "Logging configured in #{File.basename __FILE__}."
LOG.level = LOG_LEVEL
#ActiveRecord::Base.logger = LOG  # Uncomment for ActiveRecord outputs
