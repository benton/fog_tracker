module FogCostTracker
  describe BillingRecord do
    before(:each) do
      @bill = BillingRecord.create!(
        :provider       => "fake_provider_name",
        :service        => "fake_service_name",
        :account        => "fake_account_ID",
        :resource_id    => "fake_resource_ID",
        :resource_type  => "fake_resource_type",
        :start_time     => Time.now,
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

    it "is not valid without an resource ID" do
      @bill.resource_id = nil
      @bill.should_not be_valid
    end

  end
end
