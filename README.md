Cloud Cost Tracker
================
Generates BillingRecords (ActiveRecords) for each cloud computing resource
discovered by the [Fog gem](https://github.com/fog/fog)

  *ALPHA VERSION - not yet fully functional*


----------------
What is it?
----------------
The Cloud Cost Tracker periodically polls one or more cloud computing accounts and determines the state of their associated cloud computing "resources": compute instances, disk volumes, stored objects, and so on. Each time the accounts are queried, an ActiveRecord object (a BillingRecord) is created or updated for each resource, containing the cost for that resource over the period since its previous BillingRecord.


----------------
Why is it?
----------------
The Cloud Cost Tracker is intended to be a foundation library, on top of which more complex cloud billing / accounting applications can be built. Although an executable 'tracker' command-line program is included, the library is primarily intended for use from within Rails, or some other ActiveRecord context, that can generate reports based on the BillingRecords.


----------------
Installation
----------------
Install the Cloud Cost Tracker gem and your database adaptor of choice.

    gem install cloud_cost_tracker sqlite3


----------------
Usage [from within Ruby]
----------------
1) Add the BillingRecords table into your database.
  Just put `require 'CloudCostTracker/tasks'` in your Rakefile, then run

    rake db:migrate:tracker

2) In your Ruby app, `require` the gem, and set up an ActiveRecord connection. In Rails, the connection is set up for you automatically on startup, but here's an example for a non-Rails app:

    require 'cloud_cost_tracker'
    ActiveRecord::Base.establish_connection({
      :adapter => 'sqlite3', :database => 'cloud_cost_tracker.sqlite3'
    })

3) Track all accounts loaded from a YAML file (or the Hash equivalent):

    tracker = CloudCostTracker::Tracker.new(YAML::load(File.read 'accounts.yml'))
    tracker.start

  For the accounts file format, see the example below or the included `config/accounts.yml.example`.


----------------
Usage [from the command line]
----------------
1) First, generate an ActiveRecord-style database configuration file.
   Here are the contents of a sample `database.yml`:

    adapter: sqlite3
    database: cloud_cost_tracker.sqlite3
    pool: 5
    timeout: 5000

  If necessary, create the database to contain the data. The BillingRecords table will be created / updated by an ActiveRecord Migration.

2) Generate a YAML file containing your Fog accounts and their credentials:
   Here are the contents of a sample `accounts.yml`:

    AWS EC2 development account:
      :provider: AWS
      :service: Compute
      :credentials:
        :aws_access_key_id: XXXXXXXXXXXXXXXXXXXX
        :aws_secret_access_key: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      :polling_time: 180
    AWS EC2 production account:
      :provider: AWS
      :service: Compute
      :credentials:
        :aws_access_key_id: XXXXXXXXXXXXXXXXXXXX
        :aws_secret_access_key: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      :polling_time: 120
    Rackspace development account:
      :provider: Rackspace
      :service: Compute
      :credentials:
        :rackspace_api_key: XXXXXXXXXXXXXXXXXXXX
        :rackspace_username: XXXXXXXXX
      :polling_time: 180

3) Run the tracker, and point it at the both the database config file and the accounts file.

    tracker database.yml accounts.yml --migrate

  The `--migrate` argument updates the database to the latest version of the schema, and is only necessary for new databases, or when upgrading to a new version of the Tracker gem.


----------------
Development
----------------
This project is still in its early stages, but much of the framework is in place. More resource costs need to be modeled, but the patterns for the code to do so are now laid out. Helping hands are appreciated!

1) Install project dependencies.

    gem install rake bundler

2) Fetch the project code and bundle up...

    git clone https://github.com/benton/cloud_cost_tracker.git
    cd cloud_cost_tracker
    bundle

3) Create a SQLite database for development

    rake db:migrate:tracker

4) Run the tests:

    rake
