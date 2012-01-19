module FogCostTracker
  module Billing
    module AWS
      module Compute
        class ServerBillingPolicy
          # returns the cost for this resource type over some duration (in seconds)
          def getCostForTime(duration)
            0
          end
        end
      end
    end
  end
end
