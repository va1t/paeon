class EobServiceAdjustment < ActiveRecord::Base
  
  belongs_to :eob_detail
  
  #default scope hides records marked deleted
  default_scope where(:deleted => false)

  attr_accessible :claim_adjustment_group_code, 
                  :carc1, :carc2, :carc3, :carc4, :carc5, :carc6, 
                  :monetary_amount1, :monetary_amount2, :monetary_amount3, :monetary_amount4, :monetary_amount5, :monetary_amount6, 
                  :quantity1, :quantity2, :quantity3, :quantity4, :quantity5, :quantity6,
                  :created_user, :updated_user, :deleted


  # override the destory method to set the deleted boolean to true.
  def destroy
    run_callbacks :destroy do    
      self.update_column(:deleted, true)
    end
  end     

end
