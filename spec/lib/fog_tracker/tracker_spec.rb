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

  end
end
