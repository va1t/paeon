class CodesIcd9 < ActiveRecord::Base

  has_many :insurance_billing_icd9
  has_many :insurance_billing, :through => :insurance_billing_icd9

  #default scope hides records marked deleted
  default_scope where(:deleted => false)
  scope :all, :order => "code ASC"
  
  attr_accessible :code, :created_user, :deleted, :long_description, :short_description, :updated_user
    
  CODE_MAX_LENGTH = 25
  CODE_MIN_LENGTH = 3
  SHORT_MAX_LENGTH = 100
  
  validates :code, :length => {:maximum => CODE_MAX_LENGTH, :minimum => CODE_MIN_LENGTH }, :presence => true
  validates :long_description, :presence => true
  validates :short_description, :length => {:maximum => SHORT_MAX_LENGTH }, :allow_nil => true, :allow_blank => true

  validates :deleted, :inclusion => {:in => [true, false]}  
  validates :created_user, :presence => true

  # override the destory method to set the deleted boolean to true.
  def destroy
    run_callbacks :destroy do    
      self.update_column(:deleted, true)
    end
  end
    
  def display_codes
    "#{code}, #{long_description}"
  end  

  def display_codes_short
    "#{code}, #{short_description}"
  end  

end

