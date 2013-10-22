class BalanceBillPayment < ActiveRecord::Base
  belongs_to :balance_bill
  
  #default scope hides records marked deleted
  default_scope where(:deleted => false) 

  attr_accessible :balance_amount, :payment_amount,
                  :created_user, :updated_user, :deleted

  validates :deleted, :inclusion => {:in => [true, false]}
  validates :created_user, :presence => true

  # override the destory method to set the deleted boolean to true.
  def destroy
    run_callbacks :destroy do    
      self.update_column(:deleted, true)
    end
  end    
  
end
