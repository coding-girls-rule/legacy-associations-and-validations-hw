# Basic test requires
require 'minitest/autorun'
require 'minitest/pride'

# Include both the migration and the app itself
require './migration'
require './term'

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
class TermTest < Minitest::Test

  def setup
    Term.delete_all
    School.delete_all
    Course.delete_all
  end

  def test_truth
    assert true
  end

  def test_create_term
    fall_2015 = Term.new(name: "Fall 2015", starts_on: Date.new(2015, 9, 1), ends_on: Date.new(2015, 12, 15))
    fall_2015.save
    assert_equal "Fall 2015", fall_2015.name
  end

  def test_term_belongs_to_school
    fall_2015 = Term.new(name: "Fall 2015", starts_on: Date.new(2015, 9, 1), ends_on: Date.new(2015, 12, 15))
    fall_2015.save
    wesleyan = School.new(name: "Wesleyan University")
    wesleyan.save
    wesleyan.terms << fall_2015
    assert_equal wesleyan, fall_2015.school
  end

  def test_term_can_have_courses
    fall_2015 = Term.new(name: "Fall 2015", starts_on: Date.new(2015, 9, 1), ends_on: Date.new(2015, 12, 15))
    fall_2015.save
    wiz_101 = Course.new(name: "Wizarding 101")
    assert fall_2015.courses << wiz_101
  end

  def test_deleting_term_raises_error
    fall_2015 = Term.create!(name: "Fall 2015", starts_on: Date.new(2015, 9, 1), ends_on: Date.new(2015, 12, 15))
    wiz_101 = Course.create!(name: "Wizarding 101")
    fall_2015.courses << wiz_101
    fall_2015.save
    fall_2015.destroy
    assert_equal ["Cannot delete record because dependent courses exist"], fall_2015.errors.messages[:base]

  end

end
