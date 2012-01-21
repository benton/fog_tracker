module CloudCostTracker
  module Billing
    module Compute
      module AWS
        class VolumesBillingPolicy
          # returns the cost for a particular resource over some duration (in seconds)
          def get_cost_for_time(resource, duration)
            0.0
          end
        end
      end
    end
  end
end
