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
    reading_12a = Reading.new(caption: "Creating fog", url: "fogmachine.com", order_number: 12)
    assert_equal "Creating fog", reading_12a.caption
  end

  def test_reading_belong_to_a_lesson
    reading_12a = Reading.new(caption: "Creating fog", url: "fogmachine.com", order_number: 12)
    lesson_12 = Lesson.new(name: "Setting the stage", description:"We learn how to set the stage for maximum effect")
    lesson_12.readings << reading_12a
    lesson_12.save
    reading_12a.save
    assert_equal lesson_12, reading_12a.lesson
  end

  def test_reading_must_have_lesson_id
    assert_raises do
      Reading.create!(caption: "Creating fog", url: "fogmachine.com", order_number: 12)
    end
  end

  def test_reading_must_have_order_id
    assert_raises do
      lesson_12 = Lesson.create!(name: "Setting the stage", description:"We learn how to set the stage for maximum effect")
      reading = Reading.create!(caption: "Creating fog", url: "fogmachine.com", lesson_id: lesson_12.id)
    end
  end

  def test_reading_must_have_url
    assert_raises do
      lesson_12 = Lesson.create!(name: "Setting the stage", description:"We learn how to set the stage for maximum effect")
      reading = Reading.create!(caption: "Creating fog", order_number: 15, lesson_id: lesson_12.id)
    end
  end

  def test_reading_url_must_have_http_https
    assert_raises do
      lesson_12 = Lesson.create!(name: "Setting the stage", description:"We learn how to set the stage for maximum effect")
      reading = Reading.create!(caption: "Creating fog", order_number: 15, url: "this.that.com", lesson_id: lesson_12.id)
    end
  end
end
