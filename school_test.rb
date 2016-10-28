# Basic test requires
require 'minitest/autorun'
require 'minitest/pride'

# Include both the migration and the app itself
require './migration'
require './school'

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
class SchoolTest < Minitest::Test

  def setup
    Term.delete_all
    School.delete_all
  end

  def test_truth
    assert true
  end

  def test_create_school
    wesleyan = School.new(name: "Wesleyan University")
    wesleyan.save
    assert_equal "Wesleyan University", wesleyan.name
  end

  def test_add_term_to_school
    wesleyan = School.new(name: "Wesleyan University")
    wesleyan.save
    fall_2015 = Term.new(name: "Fall 2015", starts_on: 1.day.ago, ends_on: Date.today )
    assert wesleyan.terms << fall_2015
  end

  def test_school_has_courses
    wesleyan = School.create!(name: "Wesleyan University")
    fall_2015 = Term.new(name: "Fall 2015", starts_on: 1.day.ago, ends_on: Date.today )
    wesleyan.terms << fall_2015
    fall_2016 = Term.new(name: "Fall 2016", starts_on: 1.day.ago, ends_on: Date.today )
    wesleyan.terms << fall_2016
    wiz_101 = Course.create!(name: "Wizarding 101", course_code: "WIZ101")
    wiz_201 = Course.create!(name: "Advanced Spellwork", course_code: "WIZ201")
    fall_2015.courses << wiz_101
    fall_2016.courses << wiz_201
    assert_equal wiz_201, wesleyan.courses.first
    assert_equal wiz_101, wesleyan.courses.last
  end

  def test_validate_school_must_have_name
    assert_raises do
      School.create!
    end
  end
end
