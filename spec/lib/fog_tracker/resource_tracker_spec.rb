require 'spec_helper'

module FogTracker

    describe ResourceTracker do

      before(:each) do
        @tracker = ResourceTracker.new('resource_type', mock_account_tracker)
      end

      it "exposes a collection of Fog objects" do
        @tracker.collection.should == []
      end

    end

end
