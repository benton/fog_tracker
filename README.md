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

    AWS EC2 development account:
      :provider: AWS
      :service: Compute
      :credentials:
        :aws_access_key_id: XXXXXXXXXXXXXXXXXXXX
        :aws_secret_access_key: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      :polling_time: 180
	  :exclude_resources:
	  - :flavors
	  - :images
    Rackspace development account:
      :provider: Rackspace
      :service: Compute
      :credentials:
        :rackspace_api_key: XXXXXXXXXXXXXXXXXXXX
        :rackspace_username: XXXXXXXXX
      :polling_time: 180

2) Call `start` on the Tracker. It will run asynchronously, with one thread per account. At any time, you can call `start` or `stop` on it, and query the resulting collections of Fog Resource objects.

    tracker.start

3) Access the Fog object collections by passing a filter-based query String to `Tracker::query`. The query string format is: `account_name::service::provider::collection`

    # get all Compute instances across all accounts and providers
    tracker.query("*::Compute::*::servers")

    # get all Amazon EC2 Resources, of all types, across all accounts
    tracker["*::Compute::AWS::*"]	# the [] operator is the same as query()

    # get all S3 objects in a given account
    tracker["my production account::Storage::AWS::files"]

----------------
*Usage Tips*

* Instead of calling `each` on the results of every query, you can pass a single-argument block, and it will be invoked once with each resulting resource:

        tracker.query("*::*::*::*"){|r| puts "Found #{r.class} #{r.identity}"}

* You can pass a callback Proc to the Tracker at initialization, which will be invoked whenever all an account's Resources have been updated. It should accept an Array containing the updated Resources as its first parameter:

        FogTracker::Tracker.new(YAML::load(File.read 'accounts.yml'),
          :callback => Proc.new do |resources|
          	puts "Got #{resources.count} resources from account "+
    		      resources.first.tracker_account[:name]
          end
        ).start

* The resources returned from a query are all Fog::Model objects, but they are "decorated" with some extra methods for fetching the account information, or for fetching more resources. This simplifies the code that consumes the query results, because it does not have to know anything about the tracker. Here are the methods added by {FogTracker::Extensions::FogModel}:
  1. `tracker_account` returns a Hash of the Resource's account information _(:name is added; :credentials are removed)_.
  2. `tracker_query(query_string)` queries the tracker for more resources (though you cannot yet pass a block to this method).
  3. `account_resources(collection_query)` returns an Array of resources from the same account. (This is essentially shorthand for `tracker.query("account::service::provider::#{collection_query}")`)

* Any Exceptions that occur in the Tracker's polling threads are rescued and logged. If you want to take further action, you can initialize the Tracker with an `:error_callback` Proc. This is similar to the Account update `:callback` above, except that the parameter for `:error_callback` should be an Exception instead of an Array of Resources.


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
