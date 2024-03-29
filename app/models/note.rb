class Note < ActiveRecord::Base
  
  belongs_to :noteable, :polymorphic => true
  
  #default scope hides records marked deleted
  default_scope where(:deleted => false) 
  
  attr_accessible :note, :noteable_type, :noteable_id,
                  :created_user, :updated_user, :deleted


  
  # override the destory method to set the deleted boolean to true.
  def destroy
    run_callbacks :destroy do    
      self.update_column(:deleted, true)
    end
  end    
  
end
