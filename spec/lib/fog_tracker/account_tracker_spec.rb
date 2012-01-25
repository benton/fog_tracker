require 'spec_helper'

module FogTracker

    describe AccountTracker do

      before(:each) do
        @tracker = AccountTracker.new(
          FAKE_ACCOUNT_NAME, FAKE_ACCOUNT, :logger => LOG
        )
      end

      it "exposes its Hash of account information" do
        @tracker.connection.should_not == nil
      end
      it "exposes the account name" do
        @tracker.name.should == FAKE_ACCOUNT_NAME
      end
      it "exposes the connection to its Fog service" do
        @tracker.account.should == FAKE_ACCOUNT
      end
      it "exposes the connection to its logger" do
        @tracker.log.should_not == nil
      end
      it "exposes a collection of ResourceTrackers" do
        @tracker.resource_trackers.size.should be > 0
      end

      describe '#start' do
        it "sends update() to its ResourceTrackers" do
          @tracker.resource_trackers.each do |resource_tracker|
            resource_tracker.should_receive(:update)
          end
          @tracker.start
          sleep THREAD_STARTUP_DELAY # wait for background thread to start
        end
      end

      describe '#stop' do
        it "sets running? to false" do
          @tracker.start ; @tracker.stop
          @tracker.running?.should be_false
        end
        it "kills its timer thread" do
          @tracker.start ; @tracker.stop
          @tracker.resource_trackers.first.should_not_receive(:update)
          sleep THREAD_STARTUP_DELAY # wait to make sure no update()s are sent
        end
      end

      describe '#running?' do
        it "returns true if the AccountTracker is running" do
          @tracker.start
          @tracker.running?.should be_true
        end
        it "returns false if the AccountTracker is stopped" do
          @tracker.running?.should be_false
        end
      end

      describe '#tracked_types' do
        it "returns a list of Resource types tracked for its account" do
          @tracker.tracked_types.size.should be > 0
          @tracker.tracked_types.first.should be_an_instance_of String
        end
      end

    end

end