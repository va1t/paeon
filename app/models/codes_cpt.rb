class CodesCpt < ActiveRecord::Base
  
  include CommonStatus
  
  scope :all, :order => "code ASC"

  attr_accessible :code, :created_user, :long_description, :short_description, :updated_user
  attr_protected :status
    
  
  CODE_MAX_LENGTH = 25
  CODE_MIN_LENGTH = 3
  SHORT_MAX_LENGTH = 100
  
  validates :code, :length => {:maximum => CODE_MAX_LENGTH, :minimum => CODE_MIN_LENGTH }, :presence => true
  validates :long_description, :presence => true
  validates :short_description, :length => {:maximum => SHORT_MAX_LENGTH }, :allow_nil => true, :allow_blank => true
  validates :created_user, :presence => true
    
  def display_codes
    "#{code}, #{long_description}"
  end
  
  def display_codes_short
    "#{code}, #{short_description}"
  end
  
end
