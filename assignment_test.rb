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

  def test_assignment_has_many_lessons_pre_class
    sleeping_draught = Assignment.create!(name: "Sleeping Draught")
    lesson_12 = Lesson.create!(name: "Setting the stage", description:"We learn how to set the stage for maximum effect")
    sleeping_draught.pre_class_assignments << lesson_12
    sleeping_draught.save
    lesson_12.save
    assert_equal [lesson_12], sleeping_draught.pre_class_assignments
  end

  def test_can_create_lesson_from_assignment
    sleeping_draught = Assignment.create!(name: "Sleeping Draught")
    potions_lesson = sleeping_draught.pre_class_assignments.create!(name: "Potions Lesson")
    assert_equal potions_lesson.pre_class_assignment_id, sleeping_draught.id
  end

end
