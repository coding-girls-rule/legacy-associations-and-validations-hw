# Basic test requires
require 'minitest/autorun'
require 'minitest/pride'
require 'pry'

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

  def test_lesson_has_pre_class_assignment
    lesson_12 = Lesson.create!(name: "Setting the stage", description:"We learn how to set the stage for maximum effect")
    pre_assmt = Assignment.create!(name: "Chapter One")
    lesson_12.pre_class_assignment = pre_assmt
    assert_equal pre_assmt, lesson_12.pre_class_assignment
  end

  def test_deleting_a_lesson_destroys_related_readings
    reading_12a = Reading.create!(caption: "Creating fog", url: "fogmachine.com", order_number: 12)
    reading_12b = Reading.create!(caption: "Setting props", url: "props.com", order_number: 12)
    lesson_12 = Lesson.create!(name: "Setting the stage", description:"We learn how to set the stage for maximum effect")
    lesson_12.readings << reading_12a
    lesson_12.readings << reading_12b

    lesson_12.destroy

    assert_raises do Lesson.find(lesson_12.id) end
    assert_raises do Reading.find(reading_12a.id) end
    assert_raises do Reading.find(reading_12b.id) end
  end

  def test_validate_lesson_must_have_name
    assert_raises do
      Lesson.create!
    end
  end
end
