require 'spec_helper'

module FogTracker

    describe ResourceTracker do

      before(:each) do
        @tracker = ResourceTracker.new(
          ::FAKE_COLLECTION, mock_account_tracker
        )
      end

      it "exposes a collection of Fog objects" do
        @tracker.collection.should == []
      end

      describe '#update' do
        it "refreshes its resource collection from its account" do
          @tracker.update
          @tracker.collection.size.should be > 0
        end
      end
    end

end
