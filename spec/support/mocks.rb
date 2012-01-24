# returns a mock AccountTracker
def mock_account_tracker
  fake_account_tracker = double('account-tracker')
  fake_account_tracker.stub(:account).and_return(Hash.new)
  fake_account_tracker.stub(:name).and_return("fake account tracker")
  fake_account_tracker.stub(:log).and_return(Logger.new(nil))
  fake_account_tracker
end
