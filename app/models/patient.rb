class Patient < ActiveRecord::Base
  
    has_many :patient_injuries, :dependent => :destroy
    has_many :subscribers, :dependent => :destroy
    has_many :subscriber_valids, :through => :subscribers
    has_many :managed_cares, :through => :subscribers
    
    has_many :insurance_sessions, :dependent => :destroy
    has_many :notes, :as => :noteable, :dependent => :destroy
    has_many :dataerrors, :as => :dataerrorable, :dependent => :destroy
    has_many :insurance_billings, :dependent => :destroy
    has_many :balance_bills, :dependent => :destroy
    
    #group relationships
    has_many :patients_groups, :dependent => :destroy
    has_many :groups, :through => :patients_groups
   
    #provider relationships
    has_many :patients_providers, :dependent => :destroy
    has_many :providers, :through => :patients_providers
    
    before_validation :format_date
    after_save :validate_data
    
    #default scope hides records marked deleted   
    default_scope where(:deleted => false)
    
    #used for searching the first_name and last_name fields of patients
    #scope :search, lambda {|q| where("first_name LIKE ? or last_name LIKE ? or concat(last_name, ', ', first_name) LIKE ?", "%#{q}%", "%#{q}%" , "%#{q}%") }
    scope :search, lambda {|q| where("last_name LIKE ?", "%#{q}%") }
    #get list of birthdays that fall within the array of days that is passed in.
    scope :birthday, lambda {|date_array| where("DAYOFYEAR(dob) in (?)", date_array).order("last_name")}     


    attr_accessible :address1, :address2, :cell_phone, :city, :first_name, :gender, :patient_status,
                    :home_phone, :last_name, :ssn_number, :state, :work_phone, :zip, 
                    :relationship_status, :dob, :referred_to, :referred_to_type, :referred_from, :referred_from_type, :referred_from_npi,
                    :assignment_benefits, :accept_assignment, :signature_on_file, :pos_code,
                    :created_user, :updated_user, :deleted,
                    :group_ids,  #need to make available for saving associations
                    :provider_ids,  #need to make available for saving associations
                    :unformatted_dob,  #for use with datepicker
                    :search #for the ajax patient search function
                    
    attr_accessor   :unformatted_dob, :search

    GENDER = ['Male', 'Female', 'Unknown']
    RELATIONSHIP = ['Single', 'Married', 'Divorced', 'Widowed', 'Other']
    PATIENT_STATUS = ['Employed', 'Full Time Student', 'Part Time Student']
    
    
    validates :first_name, :presence => true, :length => {:minimum => STRING_MIN_LENGTH, :maximum => STRING_LRG_LENGTH }
    validates :last_name, :presence => true, :length => {:minimum => STRING_MIN_LENGTH, :maximum => STRING_LRG_LENGTH }
    validates :address1, :length => {:minimum => STRING_MIN_LENGTH, :maximum => STRING_LRG_LENGTH }
    validates :address2, :length => {:maximum => STRING_LRG_LENGTH }, :allow_nil => true, :allow_blank => true
    validates :city, :length => {:minimum => STRING_MIN_LENGTH, :maximum => STRING_MED_LENGTH }
    validates :state, :length => {:minimum => STATE_MIN_LENGTH, :maximum => STRING_SML_LENGTH }
    validates :zip, :length => {:minimum => ZIP_MIN_LENGTH, :maximum => ZIP_MAX_LENGTH }

    validates :home_phone, :allow_nil => true, :allow_blank => true, :length => {:maximum => PHONE_MAX_LENGTH }
    validates :cell_phone, :allow_nil => true, :allow_blank => true, :length => {:maximum => PHONE_MAX_LENGTH }
    validates :work_phone, :allow_nil => true, :allow_blank => true, :length => {:maximum => PHONE_MAX_LENGTH }      
    
    validates :ssn_number, :length => {:maximum => SSN_LENGTH }, :allow_nil => true, :allow_blank => true
    
    # validate the dob is before today and not before 115 years ago.  This is to make sure the dob is within a reasonable set of dates
    validates :dob, :date => {:before => Proc.new {Time.now}, :after =>  Proc.new {Time.now - 115.years},
              :message => I18n.translate('errors.dob') }
    validates :gender, :inclusion => {:in => GENDER }
    validates :relationship_status, :inclusion => {:in => RELATIONSHIP }, :allow_nil => true, :allow_blank => true
    validates :patient_status, :inclusion => {:in => PATIENT_STATUS }, :allow_nil => true, :allow_blank => true
    
    validates :deleted, :inclusion => {:in => [true, false]}
    validates :created_user, :presence => true


    def patient_name
      "#{last_name}, #{first_name}"
    end
    
    def patient_name_inv
      "#{first_name} #{last_name}"
    end
      
    def is_male
      gender = 'Male'
    end
    
    def is_female
      gender = 'Female'
    end
    
    def male?
      gender == 'Male'
    end
    
    def female?
      gender == 'Female'
    end
    
    # override the destory method to set the deleted boolean to true.
    def destroy
      if !self.insurance_sessions.blank?
        #there is an insurance_session record, dont allow destroy
        errors.add :base, "Patient has sessions associated, patient deletion is not allowed"
      else
        run_callbacks :destroy do
          self.update_column(:deleted, true)          
        end
      end
    end  
    
    # reformat the date of birth from m/d/y to y/m/d for storing in db
    def format_date      
      begin
        if !self.unformatted_dob.blank?
          self.dob = Date.strptime(self.unformatted_dob, "%m/%d/%Y").to_time(:utc)
        end
      rescue
        errors.add :base, "Invalid date for DOB."
        return false
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
      @s.push self.dataerrors.build(:message => "Patient first name is blank", :created_user => self.created_user) if self.first_name.blank? 
      @s.push self.dataerrors.build(:message => "Patient last name is blank", :created_user => self.created_user) if self.last_name.blank?
      @s.push self.dataerrors.build(:message => "Patient address is required", :created_user => self.created_user) if self.address1.blank?
      @s.push self.dataerrors.build(:message => "Patient city is blank", :created_user => self.created_user) if self.city.blank?
      @s.push self.dataerrors.build(:message => "Patient state is blank", :created_user => self.created_user) if self.state.blank?
      @s.push self.dataerrors.build(:message => "Patient zip is blank", :created_user => self.created_user) if self.zip.blank?
      @s.push self.dataerrors.build(:message => "Patient gender is blank", :created_user => self.created_user) if self.gender.blank?
      @s.push self.dataerrors.build(:message => "Patient dob is blank", :created_user => self.created_user) if self.dob.blank?
      
      referred_type = ReferredType.all 
      if self.referred_from_type == referred_type[0][:referred_type] or self.referred_from_type == referred_type[2][:referred_type]
        @s.push self.dataerrors.build(:message => "NPI for 'referred from' field in patient's record is blank", :created_user => self.created_user) if self.referred_from_npi.blank?  
      end
            
      #if there are errors, save them to the dataerrors table and return false
      if @s.count > 0
        Dataerror.store(@s) 
        @state = false
      end
      #if the error counts changed, then update all insurance_bill & balance bills
      if @original_count != @s.count
        self.insurance_billings.each { |billing| billing.validate_claim }
        self.balance_bills.each { |balance| balance.validate_balance_bill }
      end       
      return @state
    end
 
end

