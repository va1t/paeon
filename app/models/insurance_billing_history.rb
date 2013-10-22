class InsuranceBillingHistory < ActiveRecord::Base
  
    belongs_to :insurance_billing
    
    #default scope hides records marked deleted
    default_scope where(:deleted => false) 

  
    attr_accessible :status, :status_date, :edi_status, :edi_transaction,
                    :created_user, :updated_user, :deleted
  
  
    # override the destroy method to set the deleted boolean to true.
    def destroy
      run_callbacks :destroy do                   
        self.update_column(:deleted, true)
      end
    end   

    
end
