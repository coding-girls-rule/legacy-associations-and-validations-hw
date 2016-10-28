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
ActiveRecord::Migration.verbose = false
begin ApplicationMigration.migrate(:down); rescue; end
ApplicationMigration.migrate(:up)


# Finally!  Let's test the thing.
class LessonTest < Minitest::Test

  def setup
    Lesson.delete_all
    Course.delete_all
    Assignment.delete_all
    Reading.delete_all
  end


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

    lesson_12 = Lesson.create!(name: "Setting the stage", description:"We learn how to set the stage for maximum effect", course_id: 1)
    pre_assmt = Assignment.create!(name: "Chapter One", course_id: 123, percent_of_grade: 0.1 )
    lesson_12.pre_class_assignment = pre_assmt
    assert_equal pre_assmt, lesson_12.pre_class_assignment
  end

  def test_lesson_has_in_class_assignment
    lesson_12 = Lesson.create!(name: "Setting the stage", description:"We learn how to set the stage for maximum effect")
    in_class_assingment1 = Assignment.create!(name: "Chapter One", course_id: 123, percent_of_grade: 0.1 )
    lesson_12.in_class_assignment = in_class_assingment1
    assert_equal in_class_assingment1, lesson_12.in_class_assignment
  end

  def test_deleting_a_lesson_destroys_related_readings
    reading_12a = Reading.new(caption: "Creating fog", url: "https://fogmachine.com", order_number: 12)
    reading_12b = Reading.new(caption: "Setting props", url: "http://props.com", order_number: 12)
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
