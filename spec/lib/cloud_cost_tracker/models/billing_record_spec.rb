module CloudCostTracker
  describe BillingRecord do
    before(:each) do
      @bill = BillingRecord.create!(
        :provider       => "fake_provider_name",
        :service        => "fake_service_name",
        :account        => "fake_account_ID",
        :resource_id    => "fake_resource_ID",
        :resource_type  => "fake_resource_type",
        :start_time     => Time.now - CloudCostTracker::DEFAULT_POLLING_TIME,
        :stop_time      => Time.now,
        :cost_per_hour  => 0.0,
        :total_cost     => 0.0,
        :billing_codes  => "billing_code_1, billing_code_2",
      )
    end

    after(:each) do
      @bill.destroy
    end

    it "is valid with valid attributes" do
      @bill.should be_valid
    end

    it "is not valid without a provider name" do
      @bill.provider = nil
      @bill.should_not be_valid
    end
    it "is not valid without a service name" do
      @bill.service = nil
      @bill.should_not be_valid
    end
    it "is not valid without an account name" do
      @bill.account = nil
      @bill.should_not be_valid
    end
    it "is not valid without a resource ID" do
      @bill.resource_id = nil
      @bill.should_not be_valid
    end
    it "is not valid without a resource type" do
      @bill.resource_type = nil
      @bill.should_not be_valid
    end
    it "is not valid without a start time" do
      @bill.start_time = nil
      @bill.should_not be_valid
    end
    it "is not valid without a stop time" do
      @bill.stop_time = nil
      @bill.should_not be_valid
    end
    it "is not valid without an hourly cost" do
      @bill.cost_per_hour = nil
      @bill.should_not be_valid
    end
    it "is not valid without a total cost" do
      @bill.total_cost = nil
      @bill.should_not be_valid
    end

  end
end
