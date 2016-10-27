# Basic test requires
require 'minitest/autorun'
require 'minitest/pride'

# Include both the migration and the app itself
require './migration'
require './term'

# Overwrite the development database connection with a test connection.
ActiveRecord::Base.establish_connection(
  adapter:  'sqlite3',
  database: 'test.sqlite3'
)

# Gotta run migrations before we can run tests.  Down will fail the first time,
# so we wrap it in a begin/rescue.
begin ApplicationMigration.migrate(:down); rescue; end
ApplicationMigration.migrate(:up)


# Finally!  Let's test the thing.
class TermTest < Minitest::Test

  def test_truth
    assert true
  end

  def test_create_term
    fall_2015 = Term.new(name: "Fall 2015", starts_on: "2015-09-01", ends_on: "2015-12-15")
    fall_2015.save
    assert_equal "Fall 2015", fall_2015.name
  end

end
