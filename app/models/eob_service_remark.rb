class EobServiceRemark < ActiveRecord::Base
  
  belongs_to :eob_detail

  #default scope hides records marked deleted
  default_scope where(:deleted => false)
  
  attr_accessible :code_list_qualifier, :remark_code,
                  :created_user, :updated_user, :deleted


  # override the destory method to set the deleted boolean to true.
  def destroy
    run_callbacks :destroy do    
      self.update_column(:deleted, true)
    end
  end     

end
