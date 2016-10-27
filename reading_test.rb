# Basic test requires
require 'minitest/autorun'
require 'minitest/pride'

require './migration'
require './lesson'
require './reading'



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
class ReadingTest < Minitest::Test

  def test_truth
    assert true
  end

  def test_can_create_a_reading
    reading_12a = Reading.create!(caption: "Creating fog", url: "fogmachine.com", order_number: 12)
    assert_equal "Creating fog", reading_12a.caption
  end

  def test_reading_belong_to_a_lesson
    reading_12a = Reading.create!(caption: "Creating fog", url: "fogmachine.com", order_number: 12)
    lesson_12 = Lesson.create!(name: "Setting the stage", description:"We learn how to set the stage for maximum effect")
    lesson_12.readings << reading_12a
    assert_equal lesson_12, reading_12a.lesson
  end
end
