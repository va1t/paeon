class BalanceBillDetail < ActiveRecord::Base
    belongs_to :balance_bill_session
  
    #default scope hides records marked deleted
    default_scope where(:deleted => false) 

    # allows the skipping of callbacks to save on database loads  
    # use InsuranceBilling.skip_callbacks = true to set, or in update_attributes(..., :skip_callbacks => true)
    cattr_accessor :skip_callbacks

    attr_accessible :balance_bill_session_id, :amount, :description, :quantity, 
                    :created_user, :updated_user, :deleted

    validates :amount, :numericality => true
    validates :created_user, :presence => true
    validates :deleted, :inclusion => {:in => [true, false]}


    # override the destory method to set the deleted boolean to true.
    def destroy
      run_callbacks :destroy do                   
        self.update_column(:deleted, true)
      end
    end   
                    
end
