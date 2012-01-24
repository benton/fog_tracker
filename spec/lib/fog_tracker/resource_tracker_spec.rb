require 'spec_helper'

module FogTracker

    describe ResourceTracker do

      before(:each) do
        account_tracker = {"fake account name " => {}}
        #@tracker = ResourceTracker.new('fake_resource_name', account_tracker)
      end

      it "exposes a collection of Fog objects" do
        pending "mocking of account tracker"
        @tracker.collection.should == []
      end

      #describe "#query" do
      #
      #end

    end

end
