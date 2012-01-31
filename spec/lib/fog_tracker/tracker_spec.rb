module FogTracker
  describe Tracker do

    ACCOUNTS = {
      "fake account 1" => {
        :provider                 => 'AWS',
        :service                  => 'Compute',
        :credentials => {
          :aws_access_key_id      => 'X',
          :aws_secret_access_key  => 'X'
        }, :exclude_resources     => [ :spot_requests ]
      },
      "fake account 2" => {
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
            @tracker.types_for_account("fake account 1").should include(collection)
        end
      end
    end

    describe '#query' do
      it "invokes any passed code block once per resulting Resource" do
        receiver = double "resource callback object"
        receiver.stub(:callback)
        @tracker.start
        sleep THREAD_STARTUP_DELAY
        res_count = @tracker.query('*::*::*::*').count
        receiver.should_receive(:callback).exactly(res_count).times
        @tracker.query('*::*::*::*') {|r| receiver.callback(r)}
      end
      it "passes the query request to its QueryProcessor"
    end

    describe '#all' do
      it 'returns all resources tracked across all accounts' do
        AccountTracker.any_instance.stub(:all_resources).and_return(['A', 'B', 'C'])
        @tracker.start
        sleep THREAD_STARTUP_DELAY
        @tracker.all.should == ['A', 'B', 'C', 'A', 'B', 'C']
      end
    end

    describe '#start' do
      it "invokes the Tracker's callback Proc when an account is updated" do
        receiver = double "account callback object"
        receiver.stub(:callback)
        tracker = Tracker.new(ACCOUNTS, :logger => LOG,
          :callback => Proc.new {|resources| receiver.callback(resources)}
        )
        receiver.should_receive(:callback).exactly(ACCOUNTS.size).times
        tracker.start
        sleep THREAD_STARTUP_DELAY
      end
    end

  end
end
