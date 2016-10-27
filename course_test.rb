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

end
