# adds "WHERE" database search method to SQLObject
module Searchable
  def where(params)
    table = self.table_name
    where_from = params.keys.map { |col| "#{col} = ?"}.join(" AND ")
    vals = params.values
    query = self.db.execute(<<-SQL, *vals)
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
