

class Postgres::Statement

  @closed = false

  getter connection : Connection
  def initialize(@connection, @sql : String)
  end

  # Closes this object.
  def close
    return if @closed
    do_close
    @closed = true
  end

  # Returns `true` if this object is closed. See `#close`.
  def closed?
    @closed
  end

  def release_connection
    @connection.release_from_statement
  end

  # See `QueryMethods#exec`
  def exec
    perform_exec_and_release(Slice(Any).empty)
  end

  # See `QueryMethods#exec`
  def exec(args : Array)
    perform_exec_and_release(args)
  end

  # See `QueryMethods#exec`
  def exec(*args)
    # TODO better way to do it
    perform_exec_and_release(args)
  end

  # See `QueryMethods#query`
  def query
    perform_query_with_rescue Tuple.new
  end

  # See `QueryMethods#query`
  def query(args : Array)
    perform_query_with_rescue args
  end

  # See `QueryMethods#query`
  def query(*args)
    perform_query_with_rescue args
  end

  private def perform_exec_and_release(args : Enumerable) : ExecResult
    return perform_exec(args)
  ensure
    release_connection
  end

  private def perform_query_with_rescue(args : Enumerable) : ResultSet
    return perform_query(args)
  rescue e : Exception
    # Release connection only when an exception occurs during the query
    # execution since we need the connection open while the ResultSet is open
    release_connection
    raise e
  end

  protected def conn
    connection.as(Connection).connection
  end

  protected def perform_query(args : Enumerable) : ResultSet
    params = args.map { |arg| PQ::Param.encode(arg) }
    conn = self.conn
    conn.send_parse_message(@sql)
    conn.send_bind_message params
    conn.send_describe_portal_message
    conn.send_execute_message
    conn.send_sync_message
    conn.expect_frame PQ::Frame::ParseComplete
    conn.expect_frame PQ::Frame::BindComplete
    frame = conn.read
    case frame
    when PQ::Frame::RowDescription
      fields = frame.fields
    when PQ::Frame::NoData
      fields = nil
    else
      raise "expected RowDescription or NoData, got #{frame}"
    end
    ResultSet.new(self, fields)
  rescue IO::EOFError
    raise DB::ConnectionLost.new(connection)
  end

  protected def perform_exec(args : Enumerable) : ::DB::ExecResult
    result = perform_query(args)
    result.each { }
    ::DB::ExecResult.new(
      rows_affected: result.rows_affected,
      last_insert_id: 0_i64 # postgres doesn't support this
    )
  rescue IO::EOFError
    raise DB::ConnectionLost.new(connection)
  end
end
