

require "json"
require "uri"
require "digest/md5"
require "socket"
require "socket/tcp_socket"
require "socket/unix_socket"
require "openssl"

require "./postgres/error"
require "./postgres/*"

module Postgres
  extend self

  def open(uri : String)
    conn = Connection.new(uri)
    conn.connect
    yield conn
  ensure
    conn.close if conn
  end # === def open

end # === module Postgres
