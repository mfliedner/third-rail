require './lib/sql_object'
require 'sqlite3'

SQLObject.db = SQLite3::Database.new('demo/db_file.db')

class User < SQLObject
  has_many :restaurants
  has_many :favorites
end

class Restaurant < SQLObject
  belongs_to :owner
  has_many :favorites
end

class Favorite < SQLObject
  belongs_to :user
  belongs_to :restaurant
end

puts User.all[0].favorites[0].restaurant.name
