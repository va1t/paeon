class EobDetail < ActiveRecord::Base
  
  belongs_to :eob  
  has_many :eob_service_adjustments, :dependent => :destroy
  has_many :eob_service_remarks, :dependent => :destroy

  #default scope hides records marked deleted
  default_scope where(:deleted => false)
  
  attr_accessible :eob_id, :provider_id, :dos, :type_of_service,
                  :allowed_amount, :charge_amount, :copay_amount, :deductible_amount, 
                  :not_covered_amount, :other_carrier_amount, :payment_amount, :subscriber_amount,  
                  :provider_name, :created_user, :updated_user, :deleted,
                  
                  :units, :service_start, :service_end, :claim_number, :ref_authorization_number, :ref_prior_authorization

  #validates :dos, :presence => true
                    
  # override the destory method to set the deleted boolean to true.
  def destroy
    run_callbacks :destroy do    
      self.update_column(:deleted, true)
    end
  end     
                 
end

