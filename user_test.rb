# Basic test requires
require 'minitest/autorun'
require 'minitest/pride'

require './migration'
require './user'


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
class UserTest < Minitest::Test

  def setup
    User.delete_all
  end

  def test_truth
    assert true
  end

  def test_can_create_a_user
    user1 = User.create!(first_name: "Adam", last_name: "Smith", email: "adamsmithy@aol.com")
    assert_equal "adamsmithy@aol.com", user1.email
  end

  def test_user_first_name_is_required
    user1 = User.new(last_name: "Smith", email: "adamsmithy@aol.com")
    refute user1.save
  end

  def test_user_last_name_is_required
    user1 = User.new(first_name: "Adam", email: "adamsmithy@aol.com")
    refute user1.save
  end

  def test_user_email_is_required
    user1 = User.new(first_name: "Adam", last_name: "Smith")
    refute user1.save
  end

  def test_email_uniqueness
    User.create!(first_name: "Adam", last_name: "Smith", email: "adamsmithy@aol.com")
    assert_raises do
       User.create!(first_name: "Joe", last_name: "White", email: "adamsmithy@aol.com")
     end
  end

  def test_email_has_appropriate_form
    assert_raises do
       User.create!(first_name: "Joe", last_name: "White", email: "adamsmithy-aol.com")
     end
  end

end
