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
    ],
  }
  FAKE_ACCOUNTS = {FAKE_ACCOUNT_NAME => FAKE_ACCOUNT}
  module Query
    QUERY = {}  # Used in query_processor_spec.rb
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
            class FakeResourceType#{class_index} < Fog::Model
              def collection ; FakeCollectionType#{class_index}.new end
              def identity; "Fake_ID_for_Type#{class_index} " end
            end
          })
      end
    end
  end
end

def create_resource(type_index = (rand NUMBER_OF_FAKE_RESOURCE_TYPES)+1)
  Fog::FakeService::FakeProvider.const_get(
    "FakeResourceType#{type_index}"
  ).new
end
