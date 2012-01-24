require 'fog'
Fog.mock!

module FogTracker
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
    :exclude_resources => [
      :spot_requests,   # No Fog mocks for this resource
      #:account,
      #:flavors,
      #:images,
      #:addresses,
      #:volumes,
      #:snapshots,
      #:tags,
      #:servers,
      #:security_groups,
      #:key_pairs,
      #:spot_instance_requests
    ],
  }
  FAKE_ACCOUNTS = {FAKE_ACCOUNT_NAME => FAKE_ACCOUNT}
end

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
  fake_fog_connection.stub(FogTracker::FAKE_COLLECTION).and_return([ 1, 2, 3 ])
  fake_fog_connection
end

def self.mock_resource_tracker
  fake_resource_tracker = double('mock_resource_tracker')
  fake_resource_tracker.stub(:update)
  fake_resource_tracker
end
