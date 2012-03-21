desc "Runs the tracker [LOG_LEVEL=[INFO]]"
task :track do
  require File.join(File.dirname(__FILE__), '..', 'fog_tracker')

  # Setup logging
  log = FogTracker.default_logger(STDOUT)
  log.level = ::Logger.const_get((ENV['LOG_LEVEL'] || 'INFO').to_sym)

  log.info "Loading account information..."
  accounts = FogTracker.read_accounts './config/accounts.yml'

  FogTracker::Tracker.new(accounts, {:logger => log}).start
  while true do ; sleep 60 end    # Loop forever

end
