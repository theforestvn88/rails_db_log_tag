class Person < ActiveRecord::Base
  establish_connection adapter: "sqlite3", database: "test/db/test_query_log_tag.db"
  connection.create_table "people", force: true do |t|
    t.string :name
  end
end

class Book < ActiveRecord::Base
  establish_connection adapter: "sqlite3", database: "test/db/test_query_log_tag.db"
  connection.create_table "books", force: true do |t|
    t.string :name
  end
end