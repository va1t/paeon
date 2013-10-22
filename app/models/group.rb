class Group < ActiveRecord::Base
         
    has_many :rates, :as => :rateable, :dependent => :destroy    
    has_many :offices, :as => :officeable, :dependent => :destroy
    has_many :notes, :as => :noteable, :dependent => :destroy
    has_many :provider_insurances, :as => :providerable, :dependent => :destroy
    has_many :dataerrors, :as => :dataerrorable, :dependent => :destroy
    has_many :invoices, :as => :invoiceable, :dependent => :destroy
    
    # for the group to provider relationship
    has_many :groups_providers, :dependent => :destroy
    has_many :providers, :through => :groups_providers 

    has_many :patients_groups, :dependent => :destroy
    has_many :patients, :through => :patients_groups    

    has_many :insurance_sessions, :dependent => :destroy
    has_many :insurance_billings, :dependent => :destroy
    has_many :balance_bill_sessions, :dependent => :destroy

    #default scope hides records marked deleted
    default_scope where(:deleted => false)
    
    #used for searching the group_name field of groups
    scope :search, lambda {|q| where("group_name LIKE ?", "%#{q}%") }


    before_validation :format_date        
    after_save :validate_data

    attr_accessible :group_name, :ein_number, :license_number, :license_date,  :npi,
                    :insurance_accepted, :insurance_date, :office_phone, :office_fax,  
                    :created_user, :updated_user, :deleted,   
                    :invoice_method, :flat_fee, :dos_fee, :claim_percentage, :balance_percentage, :setup_fee, 
                    :cob_fee, :denied_fee, :discovery_fee, :admin_fee, :payment_terms,
                    :provider_ids,  #need to make provider_ids accessible for associating to groups
                    :patient_ids, :patient_account_numbers,
                    :unformatted_license_date,  #use in datepicker
                    :search, #for the ajax group search function
                    :selector # used for selecting between groups and/or providers
                    
    attr_accessor   :unformatted_license_date, :search, :selector
    
    validates :group_name, :presence => true, :length => {:minimum => STRING_MIN_LENGTH, :maximum => STRING_LRG_LENGTH }
    validates :license_number, :length => {:maximum => STRING_MED_LENGTH }, :allow_nil => true, :allow_blank => true 
    #validates :license_date, :date => {:after => Proc.new {Time.now}, :before => Proc.new {Time.now + 5.years}}, :allow_nil => true, :allow_blank => true
    validates :ein_number, :length => {:maximum => STRING_MED_LENGTH }
                           
    validates :office_phone, :length => {:maximum => PHONE_MAX_LENGTH }, :allow_nil => true, :allow_blank => true 
    validates :office_fax,   :length => {:maximum => PHONE_MAX_LENGTH }, :allow_nil => true, :allow_blank => true                         
    
    validates :npi, :length => {:maximum => STRING_MED_LENGTH }, :allow_nil => true, :allow_blank => true   
    
    validates :deleted, :inclusion => {:in => [true, false]}
    validates :created_user, :presence => true
    
    # override the destory method to set the deleted boolean to true.
    def destroy
      if !self.insurance_sessions.blank?
        #check insurance session.  If there is an insurance billng, then there must be a session.
        errors.add :base, "The Group is associated to a session and/or claim.  Group cannot be deleted"
      else
        run_callbacks :destroy do    
          self.update_column(:deleted, true)
        end
      end
    end  

    # reformat the license date from m/d/y to y/m/d for storing in db
    def format_date
      begin
        if !self.unformatted_license_date.blank?
          self.license_date = Date.strptime(self.unformatted_license_date, "%m/%d/%Y").to_time(:utc)
        end
      rescue
        errors.add :base, "Invalid Date"
      end
    end
  
  
    # check_data is a validation routine for the claim to ensure each session record is ready for submission
    # returns a message array of errors.  if no errors it returns an empty array.   
    # each model checks the fields within itself for completeness.
    # insurance billing has the ties to all the various records for a claim and can check all relationships required.  
    def validate_data
      @state = true
      #store the original error count, if there is a chnage to the count, then we want to update all associated insurance_billings and balance_bills
      @original_count = self.dataerrors.count      
      #first remove any old errors from the table
      self.dataerrors.clear
      
      @s = []       
      # check the necessary fields in the table
      # use the build method so the polymorphic reference is generated cleanly
      @s.push self.dataerrors.build(:message => "Group name is blank", :created_user => self.created_user) if self.group_name.blank? 
      @s.push self.dataerrors.build(:message => "Office phone number is required", :created_user => self.created_user) if self.office_phone.blank?
      @s.push self.dataerrors.build(:message => "EIN number is required", :created_user => self.created_user) if self.ein_number.blank?
      @s.push self.dataerrors.build(:message => "NPI is required for group", :created_user => self.created_user) if self.npi.blank?
            
      #if there are errors, save them to the dataerrors table and return false
      if @s.count > 0
        Dataerror.store(@s) 
        @state = false
      end
      #if the error counts changed, then update all insurance_bill & balance bills
      if @original_count != @s.count
        self.insurance_billings.each { |billing| billing.validate_claim }
        #self.balance_bills.each { |balance| balance.validate_balance_bill }
      end       
      return @state
    end
  
  
end
