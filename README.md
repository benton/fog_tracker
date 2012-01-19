Fog Cost Tracker
================
Generates BillingRecords (ActiveRecords) for each cloud computing resource
discovered by the [Fog gem](https://github.com/fog/fog)

  *ALPHA VERSION - not yet fully functional*


----------------
What is it?
----------------
The Fog Cost Tracker periodically polls one or more cloud computing accounts, and the current state of their associated "resources" -- Compute instances, disk volumes, RDS servers, and so on. Each time the accounts are queried, an ActiveRecord object (a BillingRecord) is created for each resource, containing the cost for that resource since the previous query.


----------------
Why is it?
----------------
The Fog Cost Tracker is intended to be a foundation library, on top of which more complex cloud billing / accounting applications can be built. Although an executable 'tracker' command-line program is included, the library is primarily intended for use from within Rails, or some other ActiveRecord context.


----------------
Installation
----------------
Install the Fog Cost Tracker gem and your database adaptor of choice.

    gem install fog_cost_tracker sqlite3


----------------
Usage [from within Ruby]
----------------
1) Insert the necessary tables into your database.
  First, `require 'FogCostTracker/tasks'` from your Rakefile, then run

    rake db:migrate:tracker

2) In your Ruby app, first set up an ActiveRecord connection. In Rails, this is done for you automatically, but here's an example for a non-Rails app:

    require 'fog_cost_tracker'
    ActiveRecord::Base.establish_connection({
      :adapter => 'sqlite3', :database => 'fog_cost_tracker.sqlite3'
    })

3) To track all accounts loaded from Fog:

    t = Tracker.new             # A Tracker updates all accounts detected from Fog
    t.poll_time = 60            # Update every 60 seconds
    t.start                     # Runs in the background. Call 'stop' later


----------------
Usage [from the command line]
----------------
1) First, generate an ActiveRecord-style configuration file.

  Here are the sample contents of a `tracker_db.yml`:

    adapter: sqlite3
    database: fog_cost_tracker.sqlite3
    pool: 5
    timeout: 5000

2) Create the database to contain the data. This is not necessary if using sqlite.

3) Make sure your `~/.fog` credentials file is set up correctly

    #######################################################
    # Fog Credentials File
    #
    # Key-value pairs should look like:
    # :aws_access_key_id:                 SAMPLEXXXXXXXXXXXX
    :console:
      :aws_access_key_id:
      :aws_secret_access_key:
      :bluebox_api_key:
      :bluebox_customer_id:
      :brightbox_client_id:
      :brightbox_secret:
      :go_grid_api_key:
      :go_grid_shared_secret:
      :google_storage_access_key_id:
      :google_storage_secret_access_key:
      :linode_api_key:
      :local_root:
      :new_servers_password:
      :new_servers_username:
      :public_key_path:
      :private_key_path:
      :rackspace_api_key:
      :rackspace_username:
      :slicehost_password:
      :terremark_username:
      :terremark_password:
      :zerigo_email:
      :zerigo_token:
    #
    # End of Fog Credentials File
    #######################################################

4) Run the tracker, and point it at the database config file

    tracker tracker_db.yml --migrate

  * The `--migrate` argument updates the database to the latest version of the schema, and is only necessary for new databases, or when upgrading to a new version of the Tracker gem.


----------------
Development
----------------
This project is still in its early stages, but much of the framework is in place. More resource costs need to be modeled, but the patterns for the code to do so are now laid out. Helping hands are appreciated!

1) Install project dependencies.

    gem install rake bundler

2) Fetch the project code and bundle up...

    git clone https://github.com/benton/fog_cost_tracker.git
    cd fog_cost_tracker
    bundle

3) Create a SQLite database for development

    rake db:migrate:tracker

4) Run the tests:

    rake
