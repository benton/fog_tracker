FAKE_COLLECTION = 'servers'
FAKE_ACCOUNT_NAME = 'Fake EC2 Account'
FAKE_ACCOUNT = {
  :provider     => 'AWS',
  :service      => 'Compute',
  :polling_time => 10,
  :credentials  => {
    :aws_access_key_id => "fake user",
    :aws_secret_access_key => 'fake password'
  },
  :exclude_resources => [:excluded_collection1, :excluded_collection2],
}
FAKE_ACCOUNTS = {FAKE_ACCOUNT_NAME => FAKE_ACCOUNT}

# returns a mock AccountTracker
def mock_account_tracker
  fake_account_tracker = double('mock_account_tracker')
  fake_account_tracker.stub(:account).and_return(Hash.new)
  fake_account_tracker.stub(:name).and_return("fake account tracker")
  fake_account_tracker.stub(:log).and_return(LOG)
  fake_account_tracker.stub(:connection).and_return(mock_fog_connection)
  fake_account_tracker
end

# returns a mock Fog::Connection
def mock_fog_connection
  fake_fog_connection = double('mock_fog_connection')
  fake_fog_connection.stub(FAKE_COLLECTION).and_return(
    [ 1, 2, 3 ]
  )
  fake_fog_connection
end
