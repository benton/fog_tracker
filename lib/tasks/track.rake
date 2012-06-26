desc "Runs the tracker [LOG_LEVEL=[INFO]] [TRACK_ACCOUNTS='[LIST]']"
task :track do
  require File.join(File.dirname(__FILE__), '..', 'fog_tracker')

  # Setup logging
  log = FogTracker.default_logger(STDOUT)
  log.level = ::Logger.const_get((ENV['LOG_LEVEL'] || 'INFO').upcase.to_sym)

  log.info "Loading account information..."
  accounts = FogTracker.read_accounts './config/accounts.yml'

  # If account names are specified on the command line, track only those
  chosen_accounts = (ENV['TRACK_ACCOUNTS'] || '').split(/\s+/)
  chosen_accounts.each do |account_name|
    if ! (accounts.keys.map {|k| k.to_s }).include?(account_name)
      log.error "#{account_name} not found in #{accounts.keys}"
      exit 1
    end
  end
  if ! chosen_accounts.empty?
    accounts.delete_if {|name, account| ! chosen_accounts.include?(name.to_s)}
  end

  FogTracker::Tracker.new(accounts, {:logger => log}).start
  while true do ; sleep 60 end    # Loop forever

end
