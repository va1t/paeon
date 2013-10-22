class InsuranceSessionHistory < ActiveRecord::Base
  
    belongs_to :insurance_session
    
    #default scope hides records marked deleted
    default_scope where(:deleted => false) 

    attr_accessible :insurance_session_id, :status, :status_date, 
                    :created_user, :updated_user, :deleted


    # override the destory method to set the deleted boolean to true.
    def destroy
      run_callbacks :destroy do                   
        self.update_column(:deleted, true)
      end
    end   

end
