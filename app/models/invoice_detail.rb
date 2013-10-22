class InvoiceDetail < ActiveRecord::Base
  
  belongs_to :invoice  
  belongs_to :idetailable, :polymorphic => true
  
  #default scope hides records marked deleted
  default_scope where(:deleted => false) 

  before_validation :format_date
  
  attr_accessible :idetailable_type, :idetailable_id, :status, :record_type, :dos, :provider_name,
                  :ins_paid_amount, :ins_billed_amount, :charge_amount, :patient_name, :claim_number, :insurance_name,
                  :created_user, :updated_user, :deleted,
                  :unformatted_dos
                  
  attr_accessor   :unformatted_dos
  
  validates :patient_name,   :length => {:maximum => 80  }, :allow_nil => true, :allow_blank => true
  validates :claim_number,   :length => {:maximum => 50  }, :allow_nil => true, :allow_blank => true
  validates :insurance_name, :length => {:maximum => 100 }, :allow_nil => true, :allow_blank => true
    
  validates :ins_paid_amount,   :numericality => true, :allow_nil => true, :allow_blank => true
  validates :ins_billed_amount, :numericality => true, :allow_nil => true, :allow_blank => true
  validates :charge_amount,     :numericality => true, :allow_nil => true, :allow_blank => true
  
  validates :deleted, :inclusion => {:in => [true, false]}
  validates :created_user, :presence => true

                  
  # override the destory method to set the deleted boolean to true.
  def destroy
    run_callbacks :destroy do    
      self.update_column(:deleted, true)
    end
  end    


  # reformat the dates from m/d/y to y/m/d for storing in db
  def format_date
    begin
      self.dos = Date.strptime(self.unformatted_dos, "%m/%d/%Y").to_time(:utc) if !self.unformatted_dos.blank?
    rescue
      errors.add :base, "Invalid Date(s)"
      return false
    end
  end

end
