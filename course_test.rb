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
class CourseTest < Minitest::Test

  def setup
    Course.delete_all
    Term.delete_all
    CourseStudent.delete_all
    Lesson.delete_all
    Reading.delete_all
  end

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

  def test_course_has_students
    wiz_101 = Course.create!(name: "Wizarding 101", course_code: "WIZ101")
    merlin = CourseStudent.create!(student_id: 42)
    wiz_101.course_students << merlin
    assert_equal [merlin], wiz_101.course_students
  end

  def test_cant_delete_course_with_students
    wiz_101 = Course.create!(name: "Wizarding 101", course_code: "WIZ101")
    merlin = CourseStudent.create!(student_id: 42)
    wiz_101.course_students << merlin
    refute wiz_101.destroy
  end

  def test_deleting_a_course_destroys_related_lessons
    lesson_11 = Lesson.create!(name: "Disappearing Act", description:"How to make things disappear")
    lesson_12 = Lesson.create!(name: "Setting the stage", description:"We learn how to set the stage for maximum effect")
    wiz_101 = Course.create!(name: "Wizarding 101", course_code: "WIZ101")

    wiz_101.lessons << lesson_11
    wiz_101.lessons << lesson_12
    wiz_101.destroy

    assert_raises do Course.find(wiz_101.id) end
    assert_raises do Lesson.find(lesson11.id) end
    assert_raises do Lesson.find(lesson12.id) end
  end

  def test_deleting_a_course_destroys_related_lessons_and_their_related_readings

    lesson_11 = Lesson.create!(name: "Disappearing Act", description:"How to make things disappear")
    lesson_12 = Lesson.create!(name: "Setting the stage", description:"We learn how to set the stage for maximum effect")
    reading_12a = Reading.create!(caption: "Creating fog", url: "https://fogmachine.com", order_number: 12, lesson_id: lesson_12.id)
    reading_12b = Reading.create!(caption: "Setting props", url: "http://props.com", order_number: 12, lesson_id: lesson_12.id)
    wiz_101 = Course.create!(name: "Wizarding 101", course_code: "WIZ101")

    wiz_101.lessons << lesson_11
    wiz_101.lessons << lesson_12

    wiz_101.destroy

    assert_raises do Course.find(wiz_101.id) end
    assert_raises do Lesson.find(lesson11.id) end
    assert_raises do Lesson.find(lesson12.id) end
    assert_raises do Reading.find(reading_12a.id) end
    assert_raises do Reading.find(reading_12b.id) end

  end

  def test_deleting_a_course_fails_if_it_has_an_instructor
    instructor1 = CourseInstructor.create!(primary: true)
    wiz_101 = Course.create!(name: "Wizarding 101", course_code: "WIZ101")

    wiz_101.course_instructors << instructor1
    refute wiz_101.destroy
  end

  def test_course_has_assignments
    wiz_101 = Course.create!(name: "Wizarding 101", course_code: "WIZ101")
    sleeping_draught = Assignment.new(name: "Sleeping Draught")
    assert wiz_101.assignments << sleeping_draught
  end

  def test_destroying_course_destroys_assignments
    wiz_101 = Course.create!(name: "Wizarding 101", course_code: "WIZ101")
    sleeping_draught = Assignment.new(name: "Sleeping Draught")
    wiz_101.assignments << sleeping_draught
    wiz_101.destroy
    assert_raises do
      Assignment.find(wiz_101.id)
    end
  end

  def test_course_must_have_code
    assert_raises do
      Course.create!(name: "Wizarding 101")
    end
  end

  def test_course_must_have_code
    assert_raises do
      Course.create!(course_code: "WIZ101")
    end
  end

  def test_course_code_must_be_unique_within_term
    # binding.pry
    wiz_101 = Course.create!(name: "Wizarding 101", course_code: "WIZ101")
    fall_term = Term.create!(name: "Fall 2015")
    fall_term.courses << wiz_101
    assert_raises do
      wiz_102 = Course.create!(name: "Wizarding 102", course_code: "WIZ101", term: fall_term)
    end
  end
end
