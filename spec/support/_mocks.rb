FAKE_COLLECTION = 'servers'

# returns a mock AccountTracker
def mock_account_tracker
  fake_account_tracker = double('mock_account_tracker')
  fake_account_tracker.stub(:account).and_return(Hash.new)
  fake_account_tracker.stub(:name).and_return("fake account tracker")
  fake_account_tracker.stub(:log).and_return(LOG)
  fake_account_tracker.stub(:connection).and_return(mock_fog_connection)
  fake_account_tracker
end

def mock_fog_connection
  fake_fog_connection = double('mock_fog_connection')
  fake_fog_connection.stub(FAKE_COLLECTION).and_return(
    [ 1, 2, 3 ]
  )
  fake_fog_connection
end
