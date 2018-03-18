
module Postgres
  class SimpleQuery
    getter conn, query

    def initialize(@conn : Connection, @query : String)
      conn.send_query_message(query)

      # read_all_data_rows { |row| yield row }
      while !conn.read.is_a?(Frame::ReadyForQuery)
      end
    end
  end
end
