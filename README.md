Fog Tracker
================
Uses the Fog gem to track the state of cloud computing resources across multiple accounts, with multiple service providers.

  *BETA VERSION - needs functional testing with more cloud computing providers*


----------------
What is it?
----------------
The Fog Tracker uses the [Fog gem](https://github.com/fog/fog) to periodically poll one or more cloud computing accounts, and determines the state of their associated cloud computing "Resources": compute instances, disk volumes, stored objects, and so on. The most recent state of all Resources is saved in memory (as Fog objects), and can be accessed repeatedly with no network overhead, using a simple, Regular-Expression-based query.


----------------
Why is it?
----------------
The Fog Tracker is intended to be a foundation library, on top of which more complex cloud dashboard or management applications can be built. It is a polling and query layer, allowing such applications to decouple their (read-only) requests to cloud service providers from access to the results of those requests.


----------------
Where is it? (Installation)
----------------
Install the Fog Tracker gem and its dependencies from RubyGems:

    gem install fog_tracker


----------------
How is it [done]? (Usage)
----------------
1) Require the gem, and create a `FogTracker::Tracker`. Pass it some account information in a hash, perhaps loaded from a YAML file:

    require 'fog_tracker'
    tracker = FogTracker::Tracker.new(YAML::load(File.read 'accounts.yml'))

  Here are the contents of a sample `accounts.yml`:

    AWS EC2 production account:   # The account name - can be anything
      :provider: AWS      # This is the Fog provider Module
      :service: Compute   # The Fog service Module. So, Fog::Compute::AWS
      :credentials:
        :aws_access_key_id: XXXXXXXXXXXXXXXXXXXX
        :aws_secret_access_key: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      :delay: 120 # Wait time between successive pollings (in seconds)
      :exclude_resources:
      - :account  # No need to poll for accounts - those are listed here
      - :flavors  # You may or may not want EC2 server types
      - :images   # Takes a while to list all AMIs (works though)
    AWS S3 development account:
      :provider: AWS
      :service: Storage
      :exclude_resources:
      #- :directories   # The S3 buckets - fetch the list
      - :files          # "secondary" entity to buckets - does not work yet
      :credentials:
        :aws_access_key_id: XXXXXXXXXXXXXXXXXXXX
        :aws_secret_access_key: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      :delay: 150

2) Call `start` on the Tracker. It will run asynchronously, with one thread per account. At any time, you can call `start` or `stop` on it, and query the resulting collections of Fog Resource objects.

    tracker.start

3) Access the Fog object collections by passing a filter-based query String to `Tracker::query`. The query string format is: `account_name::service::provider::collection`

    # get all Compute instances across all accounts and providers
    tracker.query("*::Compute::*::servers")

    # get all Amazon EC2 Resources, of all types, across all accounts
    tracker["*::Compute::AWS::*"]	# the [] operator is aliased to query()

    # get all S3 buckets in a given account
    tracker["my production account::Storage::AWS::directories"]

----------------
*Usage Tips*

* Instead of calling `each` on the results of every query, you can pass a single-argument block, and it will be invoked once with each resulting resource:

        tracker.query("*::*::*::*"){|r| puts "Found #{r.class} #{r.identity}"}

* You can pass a callback Proc to the Tracker at initialization, which will be invoked whenever all an account's Resources have been updated. It should accept an Array as its first parameter, which will contain the all the account's Resources. Like this:

        FogTracker::Tracker.new(YAML::load(File.read 'accounts.yml'),
          :callback => Proc.new do |resources|
          	puts "Got #{resources.count} resources from account "+
    		      resources.first.tracker_account[:name]
          end
        ).start

* The resources returned from a query are all Fog::Model objects, but they are "decorated" with some extra methods for fetching the account information, or for fetching more resources. This simplifies the code that consumes the query results, because it does not have to know anything about the tracker. Here are the some of the methods added by {FogTracker::Extensions::FogModel}:
  1. `tracker_account` returns a Hash of the Resource's account information _(:name is added; :credentials are removed)_.
  2. `tracker_description` returns a descriptive identifier (a String) that is unique to this resource.
  3. `tracker_query(query_string)` queries the tracker for more resources.
  4. `account_resources(collection_query)` also returns an Array of resources, but only from the same account. (This is essentially shorthand for `tracker_query("account::service::provider::#{collection_query}")`)

* Any Exceptions that occur in the Tracker's polling threads are rescued and logged. If you want to take further action, you can initialize the Tracker with an `:error_callback` Proc. This is similar to the Account update `:callback` above, except that the parameter for `:error_callback` should be an Exception instead of an Array of Resources.

* The Tracker can also be used synchronously. Its `update` method polls all accounts immediately, one at a time, and waits for the result (the updated Array of resource objects) in the current thread. In this mode, any exceptions are raised immediately.

----------------
*Known Limitations / Bugs*

* Some Fog resources are not currently supported, because polling them depends on making multiple calls to the service provider, once for each primary key of some other resource. These "secondary resources" include:
  * S3 Objects (Fog::Storage[:aws].files) - each is dependent
    on its bucket (Fog::Storage[:aws].directories)
  * Route 53 addresses (Fog::DNS[:aws].addresses) - each is dependent
    on its DNS zone (Fog::DNS[:aws].zones)

  Supporting these would involve hard-coding these dependencies into this gem. Currently, all Fog resource information is introspected, which allows this gem to track new Fog functionality with no update. If you really want to get information on these resources, you can traverse the Fog resource graph in your Account update `:callback`.


----------------
Who is it? (Contribution)
----------------
This Gem was created by Benton Roberts _(benton@bentonroberts.com)_, but draws heavily on the work of the [Fog project](http://fog.io/). Thanks to geemus, and to all Fog contributors.

The project is still in its early stages, and needs to be tested with many more of Fog's cloud providers. Helping hands are appreciated!

1) Install project dependencies.

    gem install rake bundler

2) Fetch the project code and bundle up...

    git clone https://github.com/benton/fog_tracker.git
    cd fog_tracker
    bundle

3) Run the tests:

    rake
