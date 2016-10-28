
require './course'

class CourseInstructor < ActiveRecord::Base
  belongs_to :course #, required: true
end
