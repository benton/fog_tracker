module CloudCostTracker
  class BillingRecord < ActiveRecord::Base
    # Validations
    validates_presence_of :provider, :service, :account, :resource_id, 
                          :resource_type, :start_time, :stop_time,
                          :cost_per_hour, :total_cost
  end
end
