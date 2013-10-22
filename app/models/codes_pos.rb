class CodesPos < ActiveRecord::Base

  #default scope hides records marked deleted
  default_scope where(:deleted => false)

  attr_accessible :code, :description, :created_user, :updated_user, :deleted
  
  CODE_MAX_LENGTH = 25
  CODE_MIN_LENGTH = 1
  SHORT_MAX_LENGTH = 100
  
  validates :code, :length => {:maximum => CODE_MAX_LENGTH, :minimum => CODE_MIN_LENGTH }, :presence => true
  validates :description, :presence => true
  validates :deleted, :inclusion => {:in => [true, false]}  
  validates :created_user, :presence => true


    # override the destory method to set the deleted boolean to true.
  def destroy
    run_callbacks :destroy do    
      self.update_column(:deleted, true)
    end
  end
  
    def display_codes
    "#{code}, #{description}"
  end  
end
