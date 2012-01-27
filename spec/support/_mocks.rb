require 'fog'
Fog.mock!

# Establish some constants
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
  module Query
    QUERY = {}  # Used in query_processor_spec.rb
  end
  class MockFogResource < Fog::Model
    #attr_accessor :tracker_account
    def identity ; "random-resource-id-#{rand 65536}" end
  end
end

# Create some fake Fog Resource and Collection Classes
NUMBER_OF_FAKE_RESOURCE_TYPES = 30
module Fog
  module FakeService
    module FakeProvider
      (1..NUMBER_OF_FAKE_RESOURCE_TYPES).each do |class_index|
        eval(%Q{
            class FakeCollectionType#{class_index} ; end
            class FakeResourceType#{class_index}
              def collection ; FakeCollectionType#{class_index}.new end
            end
          })
      end
    end
  end
end

def mock_account_tracker(num_collections = 1, resources_per_collection = 0)
  fake_account_tracker = double('mock_account_tracker')
  fake_account_tracker.stub(:account).and_return(Hash.new)
  fake_account_tracker.stub(:name).and_return(FogTracker::FAKE_ACCOUNT_NAME)
  fake_account_tracker.stub(:log).and_return(LOG)
  fake_account_tracker.stub(:connection).and_return(mock_fog_connection)
  # create an array of mock ResourceTrackers
  trackers = (1..num_collections).map do |class_index|
    mock_resource_tracker(
      Fog::FakeService::FakeProvider.const_get("FakeResourceType#{class_index}"), 
      resources_per_collection
    )
  end
  fake_account_tracker.stub(:resource_trackers).and_return(trackers)
  fake_account_tracker
end

def mock_fog_connection
  fake_fog_connection = double('mock_fog_connection')
  fake_fog_connection.stub(FogTracker::FAKE_COLLECTION).and_return(
    [ FogTracker::MockFogResource.new, FogTracker::MockFogResource.new ]
  )
  fake_fog_connection
end

def mock_resource_tracker(resource_class, number_of_resources = 0)
  fake_resource_tracker = double("mock_resource_tracker")
  resources = Array.new
  number_of_resources.times do
    resources << resource_class.new
  end
  fake_resource_tracker.stub(:collection).and_return(resources)
  fake_resource_tracker
end
