require 'rake'
require 'sequel'
require 'sequel/extensions/migration'
 
namespace :db do
 desc 'migrate database'
  task :migrate do
    DB = Sequel.connect('sqlite//db/development.sqlite3')
    Sequel::Migrator.apply(DB, './db/migrate')
  end
end