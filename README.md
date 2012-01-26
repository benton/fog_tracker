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
The Fog Tracker is intended to be a foundation library, on top of which more complex cloud dashboard or management applications can be built. It allows such applications to decouple their requests to cloud service providers from their access to the results of those requests.


----------------
Where is it? (Installation)
----------------
Install the Fog Tracker gem (and its dependencies if necessary) from RubyGems

    gem install fog_tracker [rake bundler]


----------------
How is it [done]? (Usage)
----------------
1) Just require the gem, and create a `FogTracker::Tracker`. Pass it some account information in a hash, perhaps loaded from a YAML file:

    require 'fog_tracker'
    tracker = FogTracker::Tracker.new(YAML::load(File.read 'accounts.yml'))
    tracker.start

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

2) The tracker will run asynchronously, with one thread per account. You can call `start()` and `stop()` on it, and query the resulting collections of Fog Resource objects using a filter-based query:

    # get all Compute instances across all accounts and providers
    tracker.query("*::Compute::*::servers")

    # get all Amazon EC2 Resources, of all types, across all accounts
    tracker["*::Compute::AWS::*"]	# the [] operator is the same as query()

    # get all S3 objects in a given account
    tracker["my production account::Storage::AWS::files"]

  The query string format is:    "`account name::service::provider::collection`"

  If you're tired of calling `each` on the results of every query, pass a single-argument block, and it will be invoked once with each resulting resource:

    t.query("*::*::*::*"){|r| puts "Found #{r.class} #{r.identity}"}

  You can also pass a Proc to the Tracker at initialization, which will be invoked whenever an account's Resources have been updated -- see the API docs for details.


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
