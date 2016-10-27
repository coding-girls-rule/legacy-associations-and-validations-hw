# Basic test requires
require 'minitest/autorun'
require 'minitest/pride'

require './migration'
require './course'
require './lesson'

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
class LessonTest < Minitest::Test

  def test_truth
    assert true
  end

  def test_can_create_lesson
    lesson_12 = Lesson.create!(name: "Setting the stage", description:"We learn how to set the stage for maximum effect")
    assert_equal "Setting the stage", lesson_12.name
  end

  def test_course_has_a_term
    lesson_12 = Lesson.create!(name: "Setting the stage", description:"We learn how to set the stage for maximum effect")
    wiz_101 = Course.create!(name: "Wizarding 101", course_code: "WIZ101")

    wiz_101.lessons << lesson_12
    assert_equal wiz_101, lesson_12.course
  end
end
