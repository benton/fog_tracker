require 'spec_helper'

module FogTracker
  describe Tracker do

    ACCOUNTS = {
      "fake account" => {
        :provider                 => 'AWS',
        :service                  => 'Compute',
        :credentials => {
          :aws_access_key_id      => 'X',
          :aws_secret_access_key  => 'X'
        }, :exclude_resources     => [ :spot_requests ]
      }
    }

    before(:each) do
      @tracker = Tracker.new(ACCOUNTS, :logger => LOG)
    end

    it "exposes a Hash of account information" do
      @tracker.accounts.should == ACCOUNTS
    end
    it "exposes a Logger object for reporting its activity" do
      @tracker.logger.should == LOG
    end

    describe '#types_for_account' do
      it "returns an array of collection names for the given account" do
        [ "addresses", "flavors", "images", "key_pairs", "security_groups",
          "servers", "snapshots", "tags", "volumes"].each do |collection|
            @tracker.types_for_account("fake account").should include(collection)
        end
      end
    end

    # A class for testing the Tracker's callbacks
    class CallbackReceiver
      def resource_callback(resource)
        LOG.info "Found #{resource.class} #{resource.identity}"
      end
      def account_callback(account_name)
        LOG.info "Updated account #{account_name}"
      end
    end

    describe '#query' do
      it "invokes any passed code block once per resulting Resource" do
        pending "debugging of RSpec should_receive Expectation issue"
        receiver = CallbackReceiver.new
        @tracker.start
        sleep THREAD_STARTUP_DELAY
        @tracker.query('*::*::*::*') {|r| receiver.resource_callback(r)}
        # TODO: debug this RSpec testing problem
        # At this point the callbacks have occurred - so...
        receiver.should_receive(:resource_callback) # why doesn't this work?
      end
    end

    describe '#start' do
      it "invokes the Tracker's callback Proc when an account is updated" do
        pending "debugging of RSpec should_receive Expectation issue"
        receiver = CallbackReceiver.new
        callback = Proc.new do |account_name|
          receiver.account_callback(account_name)
        end
        tracker = Tracker.new(ACCOUNTS, :logger => LOG, :callback => callback)
        tracker.start
        sleep THREAD_STARTUP_DELAY
        # TODO: debug this RSpec testing problem
        # At this point the callbacks have occurred - so...
        receiver.should_receive(:account_callback) # why doesn't this work?
      end
    end

  end
end
