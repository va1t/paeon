class Idiagnostic < ActiveRecord::Base
  
  belongs_to :idiagable, :polymorphic => true
  
  
  #default scope hides records marked deleted
  default_scope where(:deleted => false) 

  attr_accessor   :selection
  attr_accessible :idiagable_type, :idiagable_id,
                  :icd9_code, :icd10_code, :dsm_code, :dsm4_code, :dsm5_code,
                  :created_user, :updated_user, :deleted,
                  :selection #virtual attribute for the radio buttons
  
  MAXDIAG = 6
  
  validate :validate_max_diagnostic_codes, :on => :create
  validate :unique_diag, :on => :create
  validates :deleted, :inclusion => {:in => [true, false]}
  validates :created_user, :presence => true

  
  
  # override the destory method to set the deleted boolean to true.
  def destroy
    run_callbacks :destroy do    
      self.update_column(:deleted, true)
    end
  end    

  
  
  private 
  
  def unique_diag
    if !self.icd9_code.blank?
      if Idiagnostic.exists?(:idiagable_type => self.idiagable_type, :idiagable_id => self.idiagable_id, 
                            :icd9_code => self.icd9_code, :deleted => false)
      
      
      
        errors.add :base, "Error - ICD9 code was already added"
      end
    elsif !self.icd10_code.blank?
      if Idiagnostic.exists?(:idiagable_type => self.idiagable_type, :idiagable_id => self.idiagable_id, 
                            :icd10_code => self.icd10_code, :deleted => false)
        errors.add :base, "Error - ICD10 code was already added"
      end
    elsif !self.dsm_code.blank?
      if Idiagnostic.exists?(:idiagable_type => self.idiagable_type, :idiagable_id => self.idiagable_id, 
                            :dsm_code => self.dsm_code, :deleted => false)
        errors.add :base, "Error - DSM code was already added"
      end
    elsif !self.dsm4_code.blank?
      if Idiagnostic.exists?(:idiagable_type => self.idiagable_type, :idiagable_id => self.idiagable_id, 
                            :dsm4_code => self.dsm4_code, :deleted => false)
        errors.add :base, "Error - DSM4 code was already added"
      end      
    elsif !self.dsm5_code.blank?
      if Idiagnostic.exists?(:idiagable_type => self.idiagable_type, :idiagable_id => self.idiagable_id, 
                            :dsm5_code => self.dsm5_code, :deleted => false)
        errors.add :base, "Error - DSM5 code was already added"
      end
    end
  end
  
  
  def validate_max_diagnostic_codes
    if Idiagnostic.find(:all, :conditions =>['idiagable_type = ? and idiagable_id = ?', self.idiagable_type, self.idiagable_id]).size >= MAXDIAG
      errors.add :base, "You cannot have more than #{MAXDIAG} diagnosis codes."
    end
  end

end
