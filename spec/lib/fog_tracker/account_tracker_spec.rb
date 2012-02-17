module FogTracker

    describe AccountTracker do

      before(:each) do
        @account_receiver = double "account callback object"
        @account_receiver.stub(:callback)
        @error_receiver = double "error callback object"
        @error_receiver.stub(:callback)
        @tracker = AccountTracker.new(
          FAKE_ACCOUNT_NAME, FAKE_ACCOUNT, #:logger => LOG, # uncomment to debug
          :callback => Proc.new do |resources|
              @account_receiver.callback(resources)
          end,
          :error_callback => Proc.new do |exception|
              @error_receiver.callback(exception)
          end
        )
      end

      it "exposes its Hash of account information" do
        @tracker.account.should == FAKE_ACCOUNT
      end
      it "exposes the account name" do
        @tracker.name.should == FAKE_ACCOUNT_NAME
      end
      it "exposes its logger" do
        @tracker.log.should_not == nil
      end
      it "always has a delay" do
        @tracker.account[:delay].should be_an_instance_of(Fixnum)
      end

      describe '#connection' do
        context "when the provider is AWS" do
          context "when the service is Compute" do
            tracker =  AccountTracker.new("EC2 account", FAKE_ACCOUNT)
            it "exposes the connection to its Fog service" do
              tracker.connection.should_not == nil
            end
          end
          context "when the service is RDS" do
            tracker =  AccountTracker.new("EC2 account", {
              :provider     => 'AWS',
              :service      => 'RDS',
              :credentials  => {
                :aws_access_key_id => "fake user",
                :aws_secret_access_key => 'fake password'
              }
            })
            it "exposes the connection to its Fog service" do
              tracker.connection.should_not == nil
            end
          end
        end
      end

      describe '#update' do
        it "sends update() to its CollectionTrackers" do
          update_catcher = double "mock for catching CollectionTracker::update"
          update_catcher.stub(:update)
          CollectionTracker.any_instance.stub(:update) do
            update_catcher.update
          end
          update_catcher.should_receive(:update)
          @tracker.update
        end
        it "invokes its callback Proc when its account is updated" do
          @account_receiver.should_receive(:callback).
            exactly(FAKE_ACCOUNTS.size).times
          @tracker.update
        end
        context "when it encounters an Exception" do
          it "raises the Exception" do
            CollectionTracker.any_instance.stub(:update).and_raise
            (Proc.new { @tracker.update }).should raise_error
          end
        end
        it "saves the time of it's next-to-last update as @preceeding_update_time" do
          @tracker.update
          @tracker.preceeding_update_time.should == nil
          @tracker.update
          @tracker.preceeding_update_time.should_not == nil
        end
      end

      describe '#start' do
        context "when initialized with an error callback" do
          context "when it encounters an Exception" do
            it "should fire the callback" do
              CollectionTracker.any_instance.stub(:update).and_raise
              @error_receiver.should_receive(:callback).exactly(:once)
              @tracker.start
              sleep THREAD_STARTUP_DELAY
            end
          end
        end
      end

      describe '#stop' do
        it "sets running? to false" do
          @tracker.start ; @tracker.stop
          @tracker.running?.should be_false
        end
        it "kills its timer thread" do
          @tracker.start ; @tracker.stop
          @account_receiver.should_not_receive(:callback)
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

      describe '#all_resources' do
        it "returns a flattened Array of all its CollectionTrackers collections" do
          COLLECTION = [ 1, 2, 3 ]
          NUM_TYPES = @tracker.tracked_types.size
          CollectionTracker.any_instance.stub(:collection).and_return(COLLECTION)
          @tracker.all_resources.should == ((1..NUM_TYPES).map {COLLECTION}).flatten
        end
      end

    end
end
