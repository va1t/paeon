class ReferredType < ActiveRecord::Base
  #default scope hides records marked deleted
  default_scope where(:deleted => false)
  
  attr_accessible :referred_type, :perm, :created_user, :updated_user, :deleted
  
  MAX_LENGTH = 50
  
  validates :referred_type, :presence => true, :length => {:maximum => MAX_LENGTH }
  validates :perm, :inclusion => {:in => [true, false]}
  
  validates :deleted, :inclusion => {:in => [true, false]}
  validates :created_user, :presence => true
  
  
  def type_of_referral
    "#{referred_type}"
  end
  
  # override the destory method to set the deleted boolean to true.
  def destroy
    run_callbacks :destroy do    
      self.update_column(:deleted, true)
    end
  end      
end
