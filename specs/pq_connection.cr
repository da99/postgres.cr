
module Postgres
  class Connection
    getter connection
  end
end

describe PQ::Connection, "#server_parameters" do
  it "ParameterStatus frames in response to set are handeled" do
    Postgres.open(DB_URL) { |db|
      get = ->{ db.using_connection &.connection.server_parameters["standard_conforming_strings"] }
      get.call.should eq("on")
      db.exec "set standard_conforming_strings to on"
      get.call.should eq("on")
      db.exec "set standard_conforming_strings to off"
      get.call.should eq("off")
      db.exec "set standard_conforming_strings to default"
      get.call.should eq("on")
    }
  end
end

describe PQ::Connection do
  it "handles empty queries" do
    Postgres.open(DB_URL) { |db|
      db.exec ""
      db.query("") { }
      db.query_one("select 1", &.read).should eq(1)
    }
  end
end
