class CodesDsm < ActiveRecord::Base

  include CommonStatus
  scope :all, :order => "code ASC"
  
  attr_accessible :category, :code, :created_user, :long_description, :short_description, 
                  :updated_user, :version
  attr_protected :status
  
  CODE_MAX_LENGTH = 25
  VER_MAX_LENGTH = 25
  VER_MIN_LENGTH = 3
  SHORT_MAX_LENGTH = 100
  CATEGORY_MAX_LENGTH = 75

  DSM_TABLES=['DSM', 'DSM IV', 'DSM V']

  scope :dsm,  :conditions => ["version = ?", DSM_TABLES[0]], :order => "code ASC"
  scope :dsm4, :conditions => ["version = ?", DSM_TABLES[1]], :order => "code ASC"
  scope :dsm5, :conditions => ["version = ?", DSM_TABLES[2]], :order => "code ASC"


  validates :version, :length => {:maximum => VER_MAX_LENGTH, :minimum => VER_MIN_LENGTH }, :presence => true
  validates :code, :length => {:maximum => CODE_MAX_LENGTH }, :presence => true
  validates :long_description, :presence => true
  validates :short_description, :length => {:maximum => SHORT_MAX_LENGTH }, :allow_nil => true, :allow_blank => true
  validates :category, :length => {:maximum => CATEGORY_MAX_LENGTH }, :allow_nil => true, :allow_blank => true
  validates :created_user, :presence => true
  
  
  def display_codes
    "#{code}, #{long_description}"
  end

  def display_codes_short
    "#{code}, #{long_description}"
  end

end
