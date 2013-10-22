class Iprocedure < ActiveRecord::Base
      
    belongs_to :iprocedureable, :polymorphic => true
    belongs_to :codes_cpt
    belongs_to :rate
    
    has_many :dataerrors, :as => :dataerrorable, :dependent => :destroy
    
    #default scope hides records marked deleted
    default_scope where(:deleted => false) 
    
    after_save :validate_data
    
    attr_accessible :cpt_code, :iprocedureable_type, :iprocedureable_id,
                    :modifier1, :modifier2, :modifier3, :modifier4, :rate_id, :rate_override, :total_charge, :units, :sessions,
                    :diag_pointer1, :diag_pointer2, :diag_pointer3, :diag_pointer4, :diag_pointer5, :diag_pointer6,   
                    :created_user, :updated_user, :deleted
  
    MAXCPTCODES = 6
    
    validate :validate_max_procedure_codes
    validate :unique_cpt
    #validate :validate_pointers
    
    validates :deleted, :inclusion => {:in => [true, false]}
    validates :created_user, :presence => true
    
    # override the destory method to set the deleted boolean to true.
    def destroy
      run_callbacks :destroy do    
        self.update_column(:deleted, true)
      end
    end    

    
    def update_managed_care(session_id)
      # select all ins session records that have the same managed care id
      @session = InsuranceSession.find(session_id)
      @managed_care = @session.managed_care    

      if @managed_care
        # select all the billing records
        @session = 0; @units = 0; @charges = 0        
        @sessions = @managed_care.insurance_sessions
        @sessions.each do |s|
          @billings = s.insurance_billings
          @billings.each do |b|        
            @procedures = b.iprocedures
            #loop through and sum the units, session and totals
            @procedures.each do |p|
                @session += p.sessions ? p.sessions : 0
                @units += p.units ? p.units : 0
                @charges += p.total_charge ? p.total_charge : 0 
            end
          end
        end
        #store the updates into the managed care record
        @managed_care.update_attributes(:used_sessions => @session, :used_units => @units, :used_charges => @charges)
      end      
    end

    private
    
    def unique_cpt  
      @existing = Iprocedure.where(:iprocedureable_type => self.iprocedureable_type, :iprocedureable_id => self.iprocedureable_id, :cpt_code => self.cpt_code)
      @existing.each do |x|
        errors.add :base, "CPT code has already been added" if x.id != self.id      
      end    
    end
    
    
    def validate_max_procedure_codes
      if Iprocedure.find(:all, :conditions =>['iprocedureable_type = ? and iprocedureable_id = ?', self.iprocedureable_type, self.iprocedureable_id]).size >= MAXCPTCODES
        errors.add :base, "You cannot have more than #{MAXCPTCODES} procedure codes."
      end
    end
    
    def validate_pointers
      @diagnosis = Idiagnostic.find(:all, :conditions =>['idiagable_type = ? and idiagable_id = ?', self.iprocedureable_type, self.iprocedureable_id])
      # make sure the CPTs point to a diagnostic code
      case @diagnosis.size
      when 1
        if self.diag_pointer2 || self.diag_pointer3 || self.diag_pointer4 || self.diag_pointer5 || self.diag_pointer6
          errors.add :base, "Only 1 diagnostic code, #{self.cpt_code} must point to the one code"
        end
      when 2
        if self.diag_pointer3 || self.diag_pointer4 || self.diag_pointer5 || self.diag_pointer6
          errors.add :base, "#{self.cpt_code} must point to either diagnostic code"
        end
      when 3
        if self.diag_pointer4 || self.diag_pointer5 || self.diag_pointer6
          errors.add :base, "#{self.cpt_code} must point to one of the diagnostic codes"
        end
      when 4
        if self.diag_pointer5 || self.diag_pointer6
          errors.add :base, "#{self.cpt_code} must point to one of the diagnostic codes"
        end
      when 5
        if self.diag_pointer6
          errors.add :base, "#{self.cpt_code} must point to one of the diagnostic codes"
        end      
      end
      
      # at least one of the pointers must be true, otherwise CPT doesnt point to diagnosis
      if !(self.diag_pointer1 || self.diag_pointer2 || self.diag_pointer3 || self.diag_pointer4 || self.diag_pointer5 || self.diag_pointer6)
        errors.add :base, "CPT #{self.cpt_code} must point to at least one diagnostic code"
      end
      
      # make sure there is a maximum of 4 counters
      cnt = 0
      [self.diag_pointer1, self.diag_pointer2, self.diag_pointer3, self.diag_pointer4, self.diag_pointer5, self.diag_pointer6].each do |ptr|
        if ptr
          cnt += 1
        end
      end
      if cnt > 4
        errors.add :base, "CPT #{self.cpt_code} can have a maximum of 4 diagnosis pointers"
      end
    end
  
      # check_data is a validation routine for the claim to ensure each session record is ready for submission
    # returns a message array of errors.  if no errors it returns an empty array.   
    # each model checks the fields within itself for completeness.
    # insurance billing has the ties to all the various records for a claim and can check all relationships required.  
    def validate_data
      #first remove any old errors from the table
      self.dataerrors.clear
      
      @s = []       
      # check the necessary fields in the table
      # use the build method so the polymorphic reference is generated cleanly
      # check for the relationships t other tables
      if self.rate_id.blank? && self.rate_override.blank?
        @s.push self.dataerrors.build(:message => "A rate or override rate must be entered", :created_user => self.created_user)  
      end
      
      #if there are errors, save them to the dataerrors table and return false
      if @s.count > 0
        Dataerror.store(@s) 
        return false
      end
      #everything is good, return true
      return true
    end  
  
end
