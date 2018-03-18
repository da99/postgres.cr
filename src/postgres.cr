

require "json"
require "uri"
require "digest/md5"
require "socket"
require "socket/tcp_socket"
require "socket/unix_socket"
require "openssl"

module Postgres
  class ConnectionError < Exception
  end

  class Error < Exception
  end

  class RuntimeError < Error
  end

  class PG_Error < Error
    getter fields : Array(Frame::ErrorResponse::Field)

    def initialize(@fields)
      super(field_message :message)
    end

    def field_message(name)
      fields.find { |f|
        return f.message if f.name == name
      }
    end
  end

end
require "./postgres/*"
