require_relative 'db_connection'

# adds "WHERE" database search method to SQLObject
module Searchable
  def where(params)
    table = self.table_name
    where_from = params.keys.map { |col| "#{col} = ?"}.join(" AND ")
    vals = params.values
    query = DBConnection.execute(<<-SQL, *vals)
      SELECT
        *
      FROM
        #{table}
      WHERE
        #{where_from}
    SQL
    parse_all(query)
  end
end
