# Basic test requires
require 'minitest/autorun'
require 'minitest/pride'

require './migration'
require './course'
require './course_instructor'



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
class CourseInstructorTest < Minitest::Test

  def test_truth
    assert true
  end

  def test_can_create_a_course_instructor
    instructor1 = CourseInstructor.create!(primary: true)
    assert_equal true, instructor1.primary
  end

  def test_instructor_belong_to_course
    instructor1 = CourseInstructor.create!(primary: true)
    wiz_101 = Course.create!(name: "Wizarding 101", course_code: "WIZ101")
    wiz_101.course_instructors << instructor1
    assert_equal  wiz_101, instructor1.course
  end
end
