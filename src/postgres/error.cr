
module Postgres
  class Error < Exception
  end

  class Mapping_Error < Error
  end

  class Pool_Timeout_Error < Error
  end

  class Pool_Retry_Attempts_Exceeded < Error
  end

  class Connection_Lost < Error
  end

  class Connection_Error < Error
  end

  class Runtime_Error < Error
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
end # === module Postgres

