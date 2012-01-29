require 'spec_helper'

module FogTracker

    describe CollectionTracker do

      before(:each) do
        @account_tracker = AccountTracker.new(
          FAKE_ACCOUNT_NAME, FAKE_ACCOUNT, :logger => LOG
        )
        @tracker = CollectionTracker.new(
          FAKE_COLLECTION, @account_tracker
        )
      end

      it "exposes a collection of Fog objects" do
        @tracker.collection.should == []
      end

      describe '#update' do
        it "refreshes its resource collection "+
            "from its AccountTracker's connection" do
          @account_tracker.connection.should_receive(FAKE_COLLECTION)
          @tracker.update
        end
        it "attaches account information to all resources" do
          account_tracker = mock_account_tracker(5,5)
          tracker = CollectionTracker.new(FAKE_COLLECTION, account_tracker)
          tracker.update
          tracker.collection.each do |resource|
            resource.tracker_account[:name].should == FAKE_ACCOUNT_NAME
            resource.tracker_account[:credentials].should == {}
          end
        end
      end
    end

end
