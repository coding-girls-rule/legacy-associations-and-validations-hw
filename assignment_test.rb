# Basic test requires
require 'minitest/autorun'
require 'minitest/pride'

require './migration'
require './assignment'

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
class AssignmentTest < Minitest::Test

  def test_truth
    assert true
  end

  def test_can_create_assignment
    sleeping_draught = Assignment.new(name: "Sleeping Draught")
    assert sleeping_draught
  end

  def test_assignment_belongs_to_course
    sleeping_draught = Assignment.new(name: "Sleeping Draught")
    wiz_101 = Course.create!(name: "Wizarding 101", course_code: "WIZ101")
    wiz_101.assignments << sleeping_draught
    assert_equal wiz_101, sleeping_draught.course
  end

end
