
require './lesson'

class Reading < ActiveRecord::Base

  belongs_to :lesson, required: true
  validates_presence_of :order_number, :url

  default_scope { order('order_number') }

  scope :pre, -> { where("before_lesson = ?", true) }
  scope :post, -> { where("before_lesson != ?", true) }

  def clone
    dup
  end
end
