module FogTracker
  describe Tracker do

    ACCOUNTS = {
      "fake account 1" => {
        'provider'                => 'AWS',
        :service                  => 'Compute',
        :credentials => {
          'aws_access_key_id'      => 'X',
          'aws_secret_access_key'  => 'X'
        }, 'exclude_resources'     => [ 'spot_requests' ]
      },
      "fake account 2" => {
        :provider                 => 'AWS',
        'service'                 => 'Compute',
        :credentials => {
          :aws_access_key_id      => 'X',
          :aws_secret_access_key  => 'X'
        }, :exclude_resources     => [ :spot_requests ]
      }
    }

    before(:each) do
      @tracker = Tracker.new(ACCOUNTS, :logger => LOG)
      @execute_receiver = double "Query::execute receiver"
      @execute_receiver.stub(:execute)
    end

    it "exposes a Hash of account information" do
      @tracker.accounts.should == ACCOUNTS
    end
    it "exposes a Logger object for reporting its activity" do
      @tracker.logger.should == LOG
    end

    it "attaches a query processor to resources returned by the callback" do
      t = Tracker.new(ACCOUNTS, :logger => LOG,
          :callback => Proc.new do |resources|
            resources.each { |r| r._query_processor.should_not == nil }
          end
      ).update
    end

    describe '#types_for_account' do
      it "returns an array of collection names for the given account" do
        [ "addresses", "flavors", "images", "key_pairs", "security_groups",
          "servers", "snapshots", "tags", "volumes"].each do |collection|
            @tracker.types_for_account("fake account 1").should include(collection)
        end
      end
    end

    describe '#update' do
      it "calls update on all its AccountTrackers" do
        receiver = double('AccountTracker::update receiver')
        receiver.stub(:update)
        AccountTracker.any_instance.stub(:update) {receiver.update}
        receiver.should_receive(:update).exactly(ACCOUNTS.keys.size).times
        @tracker.update
      end
      it "invokes any passed code block once per resulting Resource" do
        receiver = double "resource callback object"
        @tracker.update # (NOT the call we're testing -- just getting the count)
        receiver.should_receive(:callback).exactly(@tracker.all.count).times
        @tracker.update {|resource| receiver.callback resource}
      end
    end

    describe '#preceeding_update_time' do
      context "when given an account name" do
        it "returns time of the account's next-most-recent succesful update" do
          @tracker.update
          @tracker.preceeding_update_time(ACCOUNTS.keys.first).should == nil
          @tracker.update
          @tracker.preceeding_update_time(ACCOUNTS.keys.first).should_not == nil
        end
      end
    end

    describe '#all' do
      WILDCARD_QUERY = '*::*::*::*'
      before(:each) do
        Query::QueryProcessor.any_instance.stub(:execute) do |query|
          @execute_receiver.execute(query)
          ['A', 'B', 'C']
        end
      end
      it "returns the result of the wildcard query: #{WILDCARD_QUERY}" do
        @execute_receiver.should_receive(:execute).with(WILDCARD_QUERY)
        @tracker.all.should == ['A', 'B', 'C']
      end
      it "invokes any passed code block once per resulting Resource" do
        receiver = double "resource callback object"
        receiver.should_receive(:callback).exactly(@tracker.update.size).times
        @tracker.all {|resource| receiver.callback resource}
      end
    end

    describe '#query' do
      it "invokes any passed code block once per resulting Resource" do
        receiver = double "resource callback object"
        receiver.stub(:callback)
        @tracker.update
        res_count = @tracker.query('*::*::*::*').count
        receiver.should_receive(:callback).exactly(res_count).times
        @tracker.query('*::*::*::*') {|r| receiver.callback(r)}
      end
      it "passes the query request to its QueryProcessor" do
        Query::QueryProcessor.any_instance.stub(:execute) do |query|
          @execute_receiver.execute(query)
        end
        @execute_receiver.should_receive(:execute).with("query_string")
        @tracker.query('query_string')
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
        tracker.update
      end
    end

  end
end
