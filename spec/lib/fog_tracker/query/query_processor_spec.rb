require 'spec_helper'

module FogTracker
  module Query

    describe QueryProcessor do

      QUERIES = ['*::*::*::*', '.*production::*::*::*',
        '*::Compute::*::*', '*::*::AWS::*', '*::*::*::servers']

      before(:each) do
        fake_accounts = {"fake account name " => {}}
        tracker = AccountTracker.new(
          FAKE_ACCOUNT_NAME, FAKE_ACCOUNT, :logger => LOG
        )
        @processor = QueryProcessor.new(
          {FAKE_ACCOUNT_NAME => tracker}, :logger => LOG
        )
      end

      it "should define a Query Pattern for parsing queries" do
        QueryProcessor::QUERY_PATTERN.should_not == nil
        QueryProcessor::QUERY_PATTERN.should be_an_instance_of(Regexp)
      end

      describe "#execute" do
        context "with no discovered objects" do
          it "should return an empty Array for any query" do
            QUERIES.each do |query|
              @processor.execute(query).should == []
            end
          end
        end
      end

    end
  end
end
