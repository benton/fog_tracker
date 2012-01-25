require 'spec_helper'

module FogTracker
  module Query

    describe QueryProcessor do

      QUERY['matching all Resources'] = '*::*::*::*'
      QUERY['by account name']        = '.*production::*::*::*'
      QUERY['by Fog Service']         = '*::Compute::*::*'
      QUERY['by Fog Provider']        = '*::*::AWS::*'
      QUERY['by Fog collection name'] = '*::*::*::servers'


      it "should define a Query Pattern for parsing queries" do
        QueryProcessor::QUERY_PATTERN.should_not == nil
        QueryProcessor::QUERY_PATTERN.should be_an_instance_of(Regexp)
      end

      describe "#execute" do
        context "with no discovered Resources" do
          QUERY.each do |name, query|
            it "should return an empty Array for a query #{name}" do
              QueryProcessor.new(
                {FAKE_ACCOUNT_NAME => mock_account_tracker}, :logger => LOG
              ).execute(query).should == []
            end
          end
        end

        context "with a pre-populated, diverse set of Resources" do
          before(:each) do
            @processor = QueryProcessor.new(
              {FAKE_ACCOUNT_NAME => mock_account_tracker(3)}, :logger => LOG
            )
          end

          context "when running the query matching all Resources" do
            it "should return all Resources" do
              @processor.execute(QUERY['matching all Resources']).should_not == []
              @processor.execute(QUERY['matching all Resources']).size.should == 9
            end
          end

        end

      end

    end
  end
end
