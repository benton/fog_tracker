module FogTracker
  module Extensions
    describe FogModel do

      before(:each) do
        @model = FAKE_AWS.servers.new
      end

      describe '#tracker_account' do
        context "with no collection tracker assigned" do
          it "returns an empty Hash" do
            @model.tracker_account.should == Hash.new
          end
        end
        context "with a collection tracker assigned" do
          before(:each) do
            @account_data = {   # some sample account data
              :name => 'fake account name',
              :provider => 'AWS', :service => 'Compute'
            }
            @fake_tracker = double "mock account tracker"
            @fake_tracker.stub(:clean_account_data).and_return(@account_data)
            @model._fog_collection_tracker = @fake_tracker
          end
          it "returns a Hash of the resource's acccount data" do
            @fake_tracker.should_receive(:clean_account_data)
            @model.tracker_account.should == @account_data
          end
        end
      end

      describe '#tracker_query' do
        context "with no query processor assigned" do
          it "raises a NoMethodError" do
            q = Proc.new { @model.tracker_query('XXX') }
            q.should raise_error
          end
        end
        context "with a query processor assigned" do
          before(:each) do
            @fake_processor = double "mock query processor"
            @fake_processor.stub(:query).and_return(Array.new)
            @model._query_processor = @fake_processor
          end
          it "forwards the query to its query processor" do
            @fake_processor.should_receive(:execute).with('XXX')
            @model.tracker_query('XXX')
          end
        end
      end

    end
  end
end
