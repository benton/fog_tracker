require 'spec_helper'

module FogTracker
  module Query

    describe QueryProcessor do

      NUMBER_OF_ACCOUNTS    = 8
      NUMBER_OF_COLLECTIONS = 5
      RESOURCES_PER_ACCOUNT = 2

      QUERY['matching all Resources'] = '*::*::*::*'
      QUERY['by account name']        = 'Fake Account \d+::*::*::*'
      QUERY['by Fog Service']         = '*::FakeService::*::*'
      QUERY['by Fog Provider']        = '*::*::FakeProvider::*'
      QUERY['by Fog collection name'] = '*::*::*::Fake_Collection_Type5'


      it "should define a Query Pattern for parsing queries" do
        QueryProcessor::QUERY_PATTERN.should_not == nil
        QueryProcessor::QUERY_PATTERN.should be_an_instance_of(Regexp)
      end

      describe "#execute" do
        context "with no discovered Resources" do
          # Try each of the QUERY entries above against an empty set
          QUERY.each do |name, query|
            it "should return an empty Array for a query #{name}" do
              QueryProcessor.new(
                {FAKE_ACCOUNT_NAME => mock_account_tracker}, :logger => LOG
              ).execute(query).should == []
            end
          end
        end

        context "with a pre-populated, diverse set of Resources" do
          # Try each of the QUERY entries above against a prepopulated set
          before(:each) do
            account_trackers =
              (1..NUMBER_OF_ACCOUNTS).inject({}) do |t, account_index|
                t["Fake Account #{account_index}"] = mock_account_tracker(
                  NUMBER_OF_COLLECTIONS, RESOURCES_PER_ACCOUNT
                ) ; t
              end
            @processor = QueryProcessor.new(account_trackers, :logger => LOG)
          end

          context "when running the query matching all Resources" do
            it "should return all Resources" do
              @processor.execute(QUERY['matching all Resources']).size.should ==
                NUMBER_OF_ACCOUNTS * NUMBER_OF_COLLECTIONS * RESOURCES_PER_ACCOUNT
            end
          end
          context "when running a query by account name" do
            it "should return all Resources for that account only" do
              @processor.execute(QUERY['by account name']).size.should ==
                NUMBER_OF_ACCOUNTS * NUMBER_OF_COLLECTIONS * RESOURCES_PER_ACCOUNT
              @processor.execute('wrong account::*::*::*').size.should == 0
            end
          end
          context "when running a query by Fog service name" do
            it "should return all Resources for that service only" do
              @processor.execute(QUERY['by Fog Service']).size.should ==
                NUMBER_OF_ACCOUNTS * NUMBER_OF_COLLECTIONS * RESOURCES_PER_ACCOUNT
              @processor.execute('*::wrong service::*::*').size.should == 0
            end
          end
          context "when running a query by Fog provider name" do
            it "should return all Resources for that provider only" do
              @processor.execute(QUERY['by Fog Provider']).size.should ==
                NUMBER_OF_ACCOUNTS * NUMBER_OF_COLLECTIONS * RESOURCES_PER_ACCOUNT
                @processor.execute('*::*::wrong provider::*').size.should == 0
            end
          end
          context "when running a query by Fog collection name" do
            it "should return all Resources for that collection only" do
              @processor.execute(QUERY['by Fog collection name']).size.should ==
                NUMBER_OF_ACCOUNTS * RESOURCES_PER_ACCOUNT
              @processor.execute('*::*::*::wrong collection').size.should == 0
              true
            end
          end

        end

      end

    end
  end
end
