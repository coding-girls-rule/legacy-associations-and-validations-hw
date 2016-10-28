# Basic test requires
require 'minitest/autorun'
require 'minitest/pride'

require './migration'
require './course_student'

# Overwrite the development database connection with a test connection.
ActiveRecord::Base.establish_connection(
  adapter:  'sqlite3',
  database: 'test.sqlite3'
)

# Gotta run migrations before we can run tests.  Down will fail the first time,
# so we wrap it in a begin/rescue.
ActiveRecord::Migration.verbose = false
begin ApplicationMigration.migrate(:down); rescue; end
ApplicationMigration.migrate(:up)


# Finally!  Let's test the thing.
class CourseStudentTest < Minitest::Test

  def setup
    CourseStudent.delete_all
    Course.delete_all
  end

  def test_truth
    assert true
  end

  def test_course_student_related_to_course
    merlin = CourseStudent.create!(student_id: 42)
    wiz_101 = Course.create!(name: "Wizarding 101", course_code: "WIZ101")
    wiz_101.course_students << merlin
    assert_equal wiz_101, merlin.course
  end

end
