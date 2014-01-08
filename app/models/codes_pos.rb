class CodesPos < ActiveRecord::Base

  include CommonStatus

  attr_accessible :code, :description, :created_user, :updated_user
  attr_protected :status

  CODE_MAX_LENGTH = 25
  CODE_MIN_LENGTH = 1
  SHORT_MAX_LENGTH = 100

  validates :code, :length => {:maximum => CODE_MAX_LENGTH, :minimum => CODE_MIN_LENGTH }, :presence => true
  validates :description, :presence => true
  validates :created_user, :presence => true


  def display_codes
    "#{code}, #{description}"
  end
end
