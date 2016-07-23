require_relative 'db_connection'
require_relative 'associatable'
require_relative 'searchable'
require 'active_support/inflector'

# interacts with the database, analogous to ActiveRecord::Base
class SQLObject

  extend Searchable
  extend Associatable

  # returns the columns as symbols from the corresponding database table
  def self.columns
    unless @columns
      table = self.table_name
      query = DBConnection.execute2(<<-SQL)
        SELECT
          *
        FROM
          #{table}
      SQL

      @columns = query.first.map { |col| col.to_sym }
    end

    @columns
  end

  # adds column setter and getter methods, to be called by user at the
  # end of a subclass definition
  def self.finalize!
    columns.each do |col|
      name = col.to_s
      define_method(name) do
        attributes[col]
      end

      define_method("#{name}=") do |value|
        attributes[col] = value
      end
    end
  end

  # set and get database table name (may not follow the tableize convention)
  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.tableize
  end

  # fetches all the records from the database
  def self.all
    table = self.table_name
    query = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{table}
    SQL
    parse_all(query)
  end

  # turns the query hash in ::all into proper objects
  def self.parse_all(results)
    results.map { |attr_hash| self.new(attr_hash) }
  end

  # finds a single record object based on its :id
  def self.find(id)
    table = self.table_name
    query = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{table}
      WHERE
        id = ?
      LIMIT 1
    SQL
    return nil if query.empty?
    self.new(query.first)
  end

  def initialize(params = {})
    self.class.finalize!
    params.each do |attr_name, value|
      if self.class.columns.include?(attr_name.to_sym)
        self.send("#{attr_name}=", value)
      else
        raise "unknown attribute '#{attr_name}'"
      end
    end
  end

  # stores the setters and getters for the database columns
  def attributes
    @attributes ||= {}
  end

  def attribute_values
    attributes.values
  end

  # saves to the database as #insert or #update depending on existence of :id
  def save
    self.id.nil? ? insert : update
  end

  private

  # inserts a new record in the database and retrieves its assigned :id
  def insert
    col_names = attributes.keys.join(", ")
    vals = attribute_values
    n = vals.count
    question_marks = "(#{(["?"] * n).join(", ")})"
    table = self.class.table_name
    insert_into = "#{table} (#{col_names})"
    query = DBConnection.execute(<<-SQL, *vals)
      INSERT INTO
        #{insert_into}
      VALUES
        #{question_marks}
    SQL
    self.id = DBConnection.instance.last_insert_row_id
  end

  # updates attributes of an existing database record
  def update
    update_to = attributes.keys.map { |col| "#{col} = ?"}.join(", ")
    where_to = "id = ?"
    vals = attribute_values
    vals << self.id
    table = self.class.table_name
    query = DBConnection.execute(<<-SQL, *vals)
      UPDATE
        #{table}
      SET
        #{update_to}
      WHERE
        #{where_to}
    SQL
  end

end
