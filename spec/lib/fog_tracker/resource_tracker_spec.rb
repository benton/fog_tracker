require 'spec_helper'

module FogTracker

    describe ResourceTracker do

      before(:each) do
        @account_tracker = mock_account_tracker
        @tracker = ResourceTracker.new(
          FAKE_COLLECTION, @account_tracker
        )
      end

      it "exposes a collection of Fog objects" do
        @tracker.collection.should == []
      end

      describe '#update' do
        it "refreshes its resource collection from its AccountTracker" do
          @account_tracker.connection.should_receive(FAKE_COLLECTION)
          @tracker.update
        end
      end
    end

end
