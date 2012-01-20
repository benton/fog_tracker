module FogCostTracker
  module Billing
    module Compute
      module AWS
        class SnapshotBillingPolicy
          # returns the cost for a particular resource over some duration (in seconds)
          def getCostForTime(resource, duration)
            0
          end
        end
      end
    end
  end
end
