# Basic test requires
require 'minitest/autorun'
require 'minitest/pride'
require 'pry'

require './migration'
require './assignment'

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
class AssignmentTest < Minitest::Test

  def setup
    Course.delete_all
    Assignment.delete_all
    Lesson.delete_all
  end

  def test_truth
    assert true
  end

  def test_can_create_assignment
    sleeping_draught = Assignment.new(name: "Sleeping Draught", course_id: 5, percent_of_grade: 0.5)
    assert sleeping_draught
  end

  def test_assignment_has_a_course_id
    sleeping_draught = Assignment.new(name: "Sleeping Draught", percent_of_grade: 0.5)
    assert sleeping_draught
  end

  def test_assignment_has_a_name
    sleeping_draught = Assignment.new(course_id: 5, percent_of_grade: 0.5)
    assert sleeping_draught
  end

  def test_assignment_has_a_percent_of_grade
    sleeping_draught = Assignment.new(name: "Sleeping Draught", course_id: 5)
    assert sleeping_draught
  end

  def test_assignment_belongs_to_course
    sleeping_draught = Assignment.new(name: "Sleeping Draught", course_id: 5, percent_of_grade: 0.5)
    wiz_101 = Course.create!(name: "Wizarding 101", course_code: "WIZ101")
    wiz_101.assignments << sleeping_draught
    assert_equal wiz_101, sleeping_draught.course
  end

  def test_assignment_has_many_lessons_pre_class
    sleeping_draught = Assignment.create!(name: "Sleeping Draught", course_id: 5, percent_of_grade: 0.5)
    lesson_12 = Lesson.create!(name: "Setting the stage", description:"We learn how to set the stage for maximum effect")
    sleeping_draught.pre_class_assignments << lesson_12
    sleeping_draught.save
    lesson_12.save
    assert_equal [lesson_12], sleeping_draught.pre_class_assignments
  end

  def test_can_create_lesson_from_assignment
    sleeping_draught = Assignment.create!(name: "Sleeping Draught", course_id: 5, percent_of_grade: 0.5)
    potions_lesson = sleeping_draught.pre_class_assignments.create!(name: "Potions Lesson")
    assert_equal potions_lesson.pre_class_assignment_id, sleeping_draught.id
  end

  def test_assignment_name_is_unique_within_a_course
    sleeping_draught = Assignment.new(name: "Sleeping Draught", course_id: 5, percent_of_grade: 0.5)
    wiz_101 = Course.create!(name: "Wizarding 101", course_code: "WIZ101")
    wiz_101.assignments << sleeping_draught
    assert_raises do
      Assignment.new(name: "Sleeping Draught", course_id: wiz_101.course_id, percent_of_grade: 2)
    end
  end

end
