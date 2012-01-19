DB_CONFIG_FILE = File.expand_path('../../../config/database.yml', __FILE__)
require 'active_record'

namespace :db do
  namespace :migrate do

    desc "Conforms the schema of the tracker database. "+
      "Target specific version with VERSION=x"
    task :tracker => :db_connect do
      ActiveRecord::Migrator.migrate(
        'db/migrate', ENV["VERSION"] ? ENV["VERSION"].to_i : nil
      )
    end

    task :db_connect do
      ActiveRecord::Base.establish_connection(
        YAML::load(File.open(DB_CONFIG_FILE)))
    end

  end
end
