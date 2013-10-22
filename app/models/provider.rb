class Provider < ActiveRecord::Base
  
    has_many :rates, :as => :rateable, :dependent => :destroy
    has_many :offices, :as => :officeable, :dependent => :destroy
    has_many :notes, :as => :noteable, :dependent => :destroy
    has_many :provider_insurances, :as => :providerable, :dependent => :destroy
    has_many :dataerrors, :as => :dataerrorable, :dependent => :destroy
    has_many :invoices, :as => :invoiceable, :dependent => :destroy
    
    # for the provider to group relationship    
    has_many :groups_providers, :dependent => :destroy
    has_many :groups, :through => :groups_providers
    
    # for the patient to therapsit relationship
    has_many :patients_providers, :dependent => :destroy
    has_many :patients, :through => :patients_providers

    has_many :insurance_sessions, :dependent => :destroy
    has_many :insurance_billings, :dependent => :destroy
    has_many :balance_bill_sessions, :dependent => :destroy
    
    before_validation :format_date
    after_save :validate_data
    
    #default scope hides records marked deleted
    default_scope where(:deleted => false)
    
    #used for searching the first_name and last_name fields of providers
    #scope :search, lambda {|q| where("first_name LIKE ? or last_name LIKE ? or concat(last_name, ', ', first_name) LIKE ?", "%#{q}%", "%#{q}%" , "%#{q}%") }
    scope :search, lambda {|q| where("last_name LIKE ?", "%#{q}%") }
    
    #get list of birthdays that fall within the array of days that is passed in.
    scope :birthday, lambda {|date_array| where("DAYOFYEAR(dob) in (?)", date_array).order("last_name")}
    
    attr_accessible :first_name, :last_name, :provider_identifier, :ein_number, :ssn_number, :insurance_accepted, :npi, :dob,
                    :license_number, :license_date, :signature_on_file, :signature_date, :web_site, :office_phone, :cell_phone, :home_phone, :fax_phone,
                    :upin_usin_id, :insurance_date, :email, :created_user, :updated_user, :deleted,
                    :invoice_method, :flat_fee, :dos_fee, :claim_percentage, :balance_percentage, :setup_fee,
                    :cob_fee, :denied_fee, :discovery_fee, :admin_fee, :payment_terms,
                    :group_ids,  #need to allow access to group provider ids for the association
                    :patient_ids, 
                    :unformatted_dob, #used for datepicker
                    :unformatted_signature, #used for datepicker
                    :search, #for the ajax provider search function
                    :selector # used for selecting between groups and/or providers

    attr_accessor :unformatted_dob, :unformatted_signature, :search, :selector          
     
    validates :first_name, :presence => true, :length => {:minimum => STRING_MIN_LENGTH, :maximum => STRING_LRG_LENGTH }
    validates :last_name, :presence => true, :length => {:minimum => STRING_MIN_LENGTH, :maximum => STRING_LRG_LENGTH }
    
    validates :provider_identifier, :length => {:maximum => STRING_MED_LENGTH }, :allow_nil => true, :allow_blank => true
    
    validates :ssn_number, :length => {:maximum => SSN_LENGTH }, :allow_nil => true, :allow_blank => true   
    validates :signature_on_file, :inclusion => {:in => [true, false]}
                           
    #validates :license_number, :length => {:maximum => STRING_MED_LENGTH }    
    #validates :insurance_accepted, :inclusion => {:in => [true, false]}
    
    validates :npi, :length => {:maximum => STRING_MED_LENGTH }
    #validates :web_site,   :format => {:with => REGEX_WEBSITE }, :allow_nil => true, :allow_blank => true
    
    validates :office_phone, :length => {:maximum => PHONE_MAX_LENGTH }, :allow_nil => true, :allow_blank => true
    validates :cell_phone,   :length => {:maximum => PHONE_MAX_LENGTH }, :allow_nil => true, :allow_blank => true
    validates :home_phone,   :length => {:maximum => PHONE_MAX_LENGTH }, :allow_nil => true, :allow_blank => true  

    # validate the dob is before today and not before 115 years ago.  This is to make sure the dob is within a reasonable set of dates
    validates :dob, :date => {:before => Proc.new {Time.now}, :after =>  Proc.new {Time.now - 115.years},
              :message => I18n.translate('errors.dob') }, :allow_nil => true, :allow_blank => true
    
    validates :deleted, :inclusion => {:in => [true, false]}
    validates :created_user, :presence => true
    
    
    def provider_name
      "#{last_name}, #{first_name}"
    end
    
  
    # override the destory method to set the deleted boolean to true.
    def destroy
      if !self.insurance_sessions.blank?
        # provider was used in an session and/or claim.
        errors.add :base, "Provider is asociated to a session and/or claim.  Provider cannot be deleted."
      else
        run_callbacks :destroy do    
          self.update_column(:deleted, true)
        end  
      end
    end      
  
  
    # validation routine ensure each record is ready for submission
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
      @s.push self.dataerrors.build(:message => "Provider first name is blank", :created_user => self.created_user) if self.first_name.blank?
      @s.push self.dataerrors.build(:message => "Provider last name is blank", :created_user => self.created_user) if self.last_name.blank?
      @s.push self.dataerrors.build(:message => "Provider NPI is required", :created_user => self.created_user) if self.npi.blank?
      #either the ein or ssn is required 
      @s.push self.dataerrors.build(:message => "EIN or SSN is required", :created_user => self.created_user) if self.ssn_number.blank? && self.ein_number.blank?
      @s.push self.dataerrors.build(:message => "Office phone is required", :created_user => self.created_user) if self.office_phone.blank?
            
      #if there are errors, save them to the dataerrors table and return false
      if @s.count > 0
        Dataerror.store(@s) 
        @state = false
      end
      #if the error counts changed, then update all insurance_bill & balance bills
      if @original_count != @s.count
        self.insurance_billings.each { |billing| billing.validate_claim }
        # need to rethink the validate
        # self.balance_bill_sessions.each { |balance| balance.validate_balance_bill }
      end             
      return @state
    end

    
    # reformat the date from m/d/y to y/m/d for storing in db
    def format_date
      begin
        if !self.unformatted_dob.blank?
          self.dob = Date.strptime(self.unformatted_dob, "%m/%d/%Y").to_time(:utc)
        end
        if !self.unformatted_signature.blank?
          self.signature_date = Date.strptime(self.unformatted_signature, "%m/%d/%Y").to_time(:utc)
        end
      rescue
        errors.add :base, "Invalid Date"
        return false
      end
    end

end
