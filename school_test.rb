# Basic test requires
require 'minitest/autorun'
require 'minitest/pride'

# Include both the migration and the app itself
require './migration'
require './school'

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
class SchoolTest < Minitest::Test

  def test_truth
    assert true
  end

  def test_create_school
    wesleyan = School.new(name: "Wesleyan University")
    wesleyan.save
    assert_equal "Wesleyan University", wesleyan.name
  end

end
