module FogTracker
  
  describe '#validate_accounts' do
    it "should raise an exception when no service is specified" do
      (Proc.new { FogTracker.validate_accounts(
          FAKE_ACCOUNT_NAME => FAKE_ACCOUNT.merge({:service => nil})
        )}).should raise_error
    end
    
    it "should raise an exception when no provider is specified" do
      (Proc.new { FogTracker.validate_accounts(
          FAKE_ACCOUNT_NAME => FAKE_ACCOUNT.merge({:provider => nil})
        )}).should raise_error
    end
    
    it "should raise an exception when no credentials are specified" do
      (Proc.new { FogTracker.validate_accounts(
          FAKE_ACCOUNT_NAME => FAKE_ACCOUNT.merge({:credentials => nil})
        )}).should raise_error
    end

    it "should symbolize all account keys" do
      validated_accounts = FogTracker.validate_accounts(
        FAKE_ACCOUNT_NAME => {
          'provider'     => 'AWS',
          'service'      => 'Compute',
          'delay' => 10,
          'credentials'  => {
            'aws_access_key_id' => "fake user",
            'aws_secret_access_key' => 'fake password'
          }
        }
      )
      validated_accounts.each do |name, account|
        account.each do |account_key, account_value|
          account_key.should be_a Symbol
        end
      end
    end
  end
end
