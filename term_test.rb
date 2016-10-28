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
ActiveRecord::Migration.verbose = false
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
    wesleyan = School.new(name: "Wesleyan University")
    wesleyan.save
    fall_2015.school_id = wesleyan.id
    assert fall_2015.save
  end

  def test_term_name_is_required
    assert_raises do
      Term.create!(starts_on: Date.new(2015, 9, 1), ends_on: Date.new(2015, 12, 15), school_id: 5)
    end
  end

  def test_term_start_date_is_required
    assert_raises do
      Term.create!(name: "Term Name", ends_on: Date.new(2015, 12, 15), school_id: 5)
    end
  end

  def test_term_end_date_is_required
    assert_raises do
      Term.create!(name: "Term Name", starts_on: Date.new(2015, 12, 15), school_id: 5)
    end
  end

  def test_term_shool_id_is_required
    assert_raises do
      Term.create!(name: "Fall 2015", starts_on: Date.new(2015, 9, 1), ends_on: Date.new(2015, 12, 15))
    end
  end

  def test_term_belongs_to_school
    fall_2015 = Term.new(name: "Fall 2015", starts_on: Date.new(2015, 9, 1), ends_on: Date.new(2015, 12, 15))
    wesleyan = School.new(name: "Wesleyan University")
    wesleyan.save
    fall_2015.school_id = wesleyan.id
    fall_2015.save
    wesleyan.terms << fall_2015
    assert_equal wesleyan, fall_2015.school
  end

  def test_term_can_have_courses
    fall_2015 = Term.new(name: "Fall 2015", starts_on: Date.new(2015, 9, 1), ends_on: Date.new(2015, 12, 15))
    wesleyan = School.new(name: "Wesleyan University")
    wesleyan.save
    fall_2015.school_id = wesleyan.id
    fall_2015.save
    wiz_101 = Course.new(name: "Wizarding 101", course_code: "WIZ101")
    assert fall_2015.courses << wiz_101
  end

  def test_deleting_term_raises_error
    fall_2015 = Term.create!(name: "Fall 2015", starts_on: Date.new(2015, 9, 1), ends_on: Date.new(2015, 12, 15), school_id: 1)
    wiz_101 = Course.create!(name: "Wizarding 101", course_code: "WIZ101")
    fall_2015.courses << wiz_101
    fall_2015.save
    refute fall_2015.destroy
  end

end
