
require "da_spec"

require "../src/postgres"

extend DA_SPEC

DB_URL = ENV["DATABASE_URL"]? || "postgres:///"

def with_db
  Postgres.open(DB_URL) do |db|
    yield db
  end
end

def with_connection
  Postgres.connect(DB_URL) do |conn|
    yield conn
  end
end

def escape_literal(string)
  with_connection &.escape_literal(string)
end

def escape_identifier(string)
  with_connection &.escape_identifier(string)
end

module Helper
  def self.db_version_gte(major, minor, patch = 0)
    ver = with_connection &.version
    ver[:major] >= major && ver[:minor] >= minor && ver[:patch] >= patch
  end
end

def test_decode(name, query, expected, file = __FILE__, line = __LINE__)
  it name, file, line do
    value = Postgres.open(DB_URL).query_one "select #{query}", &.read
    value.should eq(expected), file, line
  end
end

# require "./*"
require "./connection"
