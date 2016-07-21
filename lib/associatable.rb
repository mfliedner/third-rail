require_relative 'searchable'
require 'active_support/inflector'

# provide key accessors for associations
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    @class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

# provide default keys for belongs_to association
class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    default = {
      :primary_key => :id,
      :foreign_key => "#{name}_id".to_sym,
      :class_name => name.to_s.camelcase
    }
    default.merge!(options)
    @foreign_key = default[:foreign_key]
    @primary_key = default[:primary_key]
    @class_name = default[:class_name]
  end
end

# provide default keys for has_many association
class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    default = {
      :primary_key => :id,
      :foreign_key => "#{self_class_name.to_s.downcase}_id".to_sym,
      :class_name => name.to_s.singularize.capitalize
    }
    default.merge!(options)
    @foreign_key = default[:foreign_key]
    @primary_key = default[:primary_key]
    @class_name = default[:class_name]
  end
end

# adds associations to SQLObject
module Associatable
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    self.assoc_options[name] = options
    define_method(name) do
      key_val = self.send(options.foreign_key)
      options.model_class.where(options.primary_key => key_val).first
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.name, options)
    self.assoc_options[name] = options
    define_method(name) do
      key_val = self.send(options.primary_key)
      options.model_class.where(options.foreign_key => key_val)
    end
  end

  def has_one_through(name, through_name, source_name)
    define_method(name) do
      through = self.class.assoc_options[through_name]
      source = through.model_class.assoc_options[source_name]

      through_table = through.table_name
      through_pk = through.primary_key
      through_fk = through.foreign_key

      source_table = source.table_name
      source_pk = source.primary_key
      source_fk = source.foreign_key

      key = self.send(through_fk)
      query = DBConnection.execute(<<-SQL, key)
        SELECT
          #{source_table}.*
        FROM
          #{through_table}
        JOIN
          #{source_table}
        ON
          #{through_table}.#{source_fk} = #{source_table}.#{source_pk}
        WHERE
          #{through_table}.#{through_pk} = ?
      SQL
      return nil if query.empty?
      # source.model_class.parse_all(query).first
      source.model_class.new(query.first)
    end
  end

  # stores association keys for join (through) queries
  def assoc_options
    @assoc_options ||= {}
    @assoc_options
  end
end

class SQLObject
  extend Associatable
end
