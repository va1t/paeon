class InsuredType < ActiveRecord::Base
  
  #default scope hides records marked deleted
  default_scope where(:deleted => false)
  
  attr_accessible :name, :perm, :created_user, :updated_user, :deleted
  
  TYPE_MAX_LENGTH = 50
  
  validates :name, :presence => true, :length => {:maximum => TYPE_MAX_LENGTH }
  validates :perm, :inclusion => {:in => [true, false]}
  
  validates :deleted, :inclusion => {:in => [true, false]}
  validates :created_user, :presence => true

  # override the destory method to set the deleted boolean to true.
  def destroy
    run_callbacks :destroy do    
      self.update_column(:deleted, true)
    end
  end    
end
