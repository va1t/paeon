class GroupsProvider < ActiveRecord::Base
  
  #default scope hides records marked deleted
  default_scope where(:deleted => false)
  
  belongs_to :group
  belongs_to :provider
  
  attr_accessible :group_id, :provider_id, :created_user, :deleted, :updated_user
  
  
  #validates :created_user, :presence => true  
  validates :deleted, :inclusion => {:in => [true, false]}
  
  
  # override the destory method to set the deleted boolean to true.
  def destroy
    run_callbacks :destroy do    
      self.update_column(:deleted, true)
    end
  end
end
