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
  module Query
    QUERY = {}  # Used in query_processor_spec.rb
  end
end

# Some Mock Fog Resource and Collection Classes
module Fog
  module FakeService
    module FakeProvider
      class FakeCollectionType1 ; end
      class FakeResourceType1
        def collection ; FakeCollectionType1.new end
      end
      class FakeCollectionType2 ; end
      class FakeResourceType2
        def collection ; FakeCollectionType2.new end
      end
      class FakeCollectionType3 ; end
      class FakeResourceType3
        def collection ; FakeCollectionType3.new end
      end
    end
  end
end

def mock_account_tracker(number_of_resources_per_collection = 0)
  fake_account_tracker = double('mock_account_tracker')
  fake_account_tracker.stub(:account).and_return(Hash.new)
  fake_account_tracker.stub(:name).and_return("fake account tracker")
  fake_account_tracker.stub(:log).and_return(LOG)
  fake_account_tracker.stub(:connection).and_return(mock_fog_connection)
  fake_account_tracker.stub(:resource_trackers).and_return(
    [
      mock_resource_tracker(
        Fog::FakeService::FakeProvider::FakeResourceType1,
        number_of_resources_per_collection
      ),
      mock_resource_tracker(
        Fog::FakeService::FakeProvider::FakeResourceType2,
        number_of_resources_per_collection
      ),
      mock_resource_tracker(
        Fog::FakeService::FakeProvider::FakeResourceType3,
        number_of_resources_per_collection
      ),
    ]
  )
  fake_account_tracker
end

def mock_fog_connection
  fake_fog_connection = double('mock_fog_connection')
  fake_fog_connection.stub(FogTracker::FAKE_COLLECTION).and_return([ 1, 2, 3 ])
  fake_fog_connection
end

def mock_resource_tracker
  fake_resource_tracker = double('mock_resource_tracker')
  fake_resource_tracker.stub(:update)
  fake_resource_tracker
end

def mock_fog_resource(resource_class)
  fake_resource = resource_class.new
  fake_collection_class =
  fake_resource.stub(:collection).and_return(
    collection_class.new
  )
  fake_resource
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
