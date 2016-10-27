# Basic test requires
require 'minitest/autorun'
require 'minitest/pride'

require './migration'
require './course'

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
class CourseTest < Minitest::Test

  def test_truth
    assert true
  end

  def test_can_create_course
    wizarding_101 = Course.new(name: "Wizarding 101", course_code: "WIZ101")
    assert_equal "Wizarding 101", wizarding_101.name
  end

  def test_course_has_a_term
    wiz_101 = Course.create!(name: "Wizarding 101", course_code: "WIZ101")
    fall_2015 = Term.create!(name: "Fall 2015")
    fall_2015.courses << wiz_101
    assert_equal fall_2015, wiz_101.term
  end
end
