
describe "Connection#initialize" do
  it "raises on bad connections" do
    assert_raises(Postgres::Connection_Error) {
      Postgres.open("postgres://localhost:5433") { |db|
      }
    }
  end
end

