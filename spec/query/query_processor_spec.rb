require 'spec_helper'

module FogTracker
  module Query

    describe QueryProcessor do

      before(:each) do
        fake_accounts = {"fake account name " => {}}
        @processor = QueryProcessor.new(fake_accounts)
      end

      it "should define a Regular Expression for parsing queries" do
        QueryProcessor::QUERY_PATTERN.should_not == nil
        QueryProcessor::QUERY_PATTERN.class.should == Regexp
      end

    end
  end
end
