require 'spec_helper'
require 'fog'

module FogTracker

    describe AccountTracker do

      before(:each) do
        @tracker = AccountTracker.new(
          FAKE_ACCOUNT_NAME, FAKE_ACCOUNT, :logger => LOG
        )
      end

      it "exposes its Hash of Account information" do
        @tracker.connection.should_not == nil
      end
      it "exposes the account name" do
        @tracker.name.should == FAKE_ACCOUNT_NAME
      end
      it "exposes the connection to its Fog Service" do
        @tracker.account.should == FAKE_ACCOUNT
      end
      it "exposes the connection to its Logger" do
        @tracker.log.should_not == nil
      end
      it "exposes a collection of ResourceTrackers" do
        @tracker.resource_trackers.size.should be > 0
      end

      describe '#start' do
        it "sets running? to true"
        it "sends update() to all its ResourceTrackers"
      end

      describe '#stop' do
        it "sets running? to false"
        it "kills its timer thread"
      end

      describe '#running?' do
        it "returns true if the AccountTracker has been started"
        it "returns false if the AccountTracker has been stopped"
      end

      describe '#tracked_types' do
        it "returns a list of Resource types tracked for its account"
      end

    end

end
