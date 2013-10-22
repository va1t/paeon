class Subscriber < ActiveRecord::Base
    
    belongs_to :patient
    belongs_to :insurance_company
    
    has_many :managed_cares, :dependent => :destroy
    has_many :subscriber_valids, :dependent => :destroy
    has_many :insurance_billings
    has_many :dataerrors, :as => :dataerrorable, :dependent => :destroy    
    
  
    GENDER = ['Male', 'Female', 'Unknown']
    INSURANCE_PRIORITY = ['Primary', 'Secondary', 'Tertary', 'Patient']
    
    #default scope hides records marked deleted
    default_scope where(:deleted => false) 
        
    
    before_save :format_date
    after_save :validate_data
    
    attr_accessible :patient_id, :insurance_company_id, :ins_policy, :ins_group, :ins_priority, :start_date,
                    :type_patient, :type_patient_other_description, :type_insurance, :type_insurance_other_description,
                    :subscriber_first_name, :subscriber_last_name, :subscriber_gender, :subscriber_dob, :same_address_patient, :same_as_patient,
                    :subscriber_address1, :subscriber_address2, :subscriber_city, :subscriber_state, :subscriber_zip, :subscriber_ssn_number,
                    :employer_name, :employer_address1, :employer_address2, :employer_city, :employer_state, :employer_zip, :employer_phone,
                    :created_user, :updated_user, :deleted,
                    :unformatted_start_date, :unformatted_subscriber_dob
                    
    attr_accessor   :unformatted_start_date, :unformatted_subscriber_dob
  
    INSURED_MAX_LENGTH = 50
    SUB_MAX_LENGTH = 40
    PATIENT_MAX_LENGTH = 25
    DESCRIPTION_MAX_LENGTH = 100
    EMPLOYER_NAME = 100
    
    
    #these ids are pointers into other tables
    validates :patient_id, :presence => true, :numericality => {:only_integer => true}
    validates :insurance_company_id, :presence => true, :numericality => {:only_integer => true}  
    
    validates :ins_group,    :length => {:maximum => INSURED_MAX_LENGTH }
    validates :ins_policy,   :length => {:maximum => INSURED_MAX_LENGTH }
    validates :ins_priority, :length => {:maximum => INSURED_MAX_LENGTH }, :inclusion => { :in => INSURANCE_PRIORITY }
    
    validates :type_patient,  :length => {:maximum => PATIENT_MAX_LENGTH }
    validate :validate_patient_relationship
    validates :type_patient_other_description, :length => {:maximum => DESCRIPTION_MAX_LENGTH }, :allow_nil => true, :allow_blank => true
              
    validates :type_insurance, :length => {:maximum => INSURED_MAX_LENGTH }
    validates :type_insurance_other_description, :length => {:maximum => DESCRIPTION_MAX_LENGTH }, :allow_nil => true, :allow_blank => true
    
    #validates :start_date, :date => { :before => Proc.new{Time.now}, :message => I18n.translate('errors.subscriber.start_date')}
    
    validates :subscriber_first_name,  :length => {:minimum => STRING_MIN_LENGTH, :maximum => SUB_MAX_LENGTH }, :allow_nil => true, :allow_blank => true
    validates :subscriber_last_name,   :length => {:minimum => STRING_MIN_LENGTH, :maximum => SUB_MAX_LENGTH }, :allow_nil => true, :allow_blank => true   
    
    # validate the dob is before today and not before 115 years ago.  This is to make sure the dob is within a reasonable set of dates
    validates :subscriber_dob, :date => {:before => Proc.new {Time.now}, :after =>  Proc.new {Time.now - 115.years},
              :message => I18n.translate('errors.dob') }, :allow_nil => true, :allow_blank => true

    validates :subscriber_gender, :inclusion => {:in => GENDER}
    
    #validates :employer_name,     :length => {:minimum => STRING_MIN_LENGTH, :maximum => EMPLOYER_NAME }
    #validates :employer_address1, :length => {:minimum => STRING_MIN_LENGTH, :maximum => STRING_LRG_LENGTH }
    #validates :employer_address2, :length => {:maximum => STRING_LRG_LENGTH }, :allow_nil => true, :allow_blank => true
    #validates :employer_city,     :length => {:minimum => STRING_MIN_LENGTH, :maximum => STRING_MED_LENGTH }
    #validates :employer_state,    :length => {:minimum => STRING_MIN_LENGTH, :maximum => STRING_SML_LENGTH }
    #validates :employer_zip,      :format => {:with => REGEX_ZIP }, 
    #                              :length => {:minimum => ZIP_MIN_LENGTH, :maximum => ZIP_MAX_LENGTH }
  
    validates :employer_phone,    :length => {:maximum => PHONE_MAX_LENGTH }  
    
    validates :deleted, :inclusion => {:in => [true, false]}
    validates :created_user, :presence => true
    
  
    # override the destory method to set the deleted boolean to true.
    def destroy
      if !self.insurance_billings.blank?
        # the patient insured record is used within insurance_billings, dont allow deletes
        errors.add :base, "The patient insured record is used within a cliam, deletions of the insured record are not allowed."
      else
        run_callbacks :destroy do    
          self.update_column(:deleted, true)
        end  
      end
    end
    
    # if the type_patient is self, then the subscriber name and patient name must be the same.
    # if different, then display an error
    def validate_patient_relationship
      @patient = Patient.find(self.patient_id)
      
      if self.type_patient == "Self" && @patient.patient_name.downcase != self.subscriber_name.downcase
        errors.add :base, "Relationship box equals 'Self' but the patient's name and subscriber's name is different.  Change the relationship status or edit the subscriber's name to match the patient."
      end
    end
    
    
    # reformat the date of service from m/d/y to y/m/d for sotring in db
    def format_date
      begin 
        if !self.unformatted_start_date.blank?
          self.start_date = Date.strptime(self.unformatted_start_date, "%m/%d/%Y").to_time(:utc)
        end
        if !self.unformatted_subscriber_dob.blank?
          self.subscriber_dob = Date.strptime(self.unformatted_subscriber_dob, "%m/%d/%Y").to_time(:utc)
        end   
      rescue
        errors.add :base, "Invalid date"
        return false
      end 
    end
    
    def subscriber_name
      "#{subscriber_last_name}, #{subscriber_first_name}"  
    end
    
    def insurance_company_name
      if insurance_company
        "#{insurance_company.name}"
      else
        "Not Selected"
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
      
      # the group numbe is not always avaialble.  Cannot check for it.
      #@s.push self.dataerrors.build(:message => "Insured's group number is blank", :created_user => self.created_user) if self.ins_group.blank? 
      @s.push self.dataerrors.build(:message => "Insured's policy number is blank", :created_user => self.created_user) if self.ins_policy.blank?      
      @s.push self.dataerrors.build(:message => "Subscriber's first name is blank", :created_user => self.created_user) if self.subscriber_first_name.blank?
      @s.push self.dataerrors.build(:message => "Subscriber's last name is blank", :created_user => self.created_user) if self.subscriber_last_name.blank?
      
      # subscriber's dob is normally avaialbe, but there are cases when it is not.
      #@s.push self.dataerrors.build(:message => "Subscriber's DOB is required", :created_user => self.created_user) if self.subscriber_dob.blank?      
      @s.push self.dataerrors.build(:message => "Subscriber's gender is required", :created_user => self.created_user) if self.subscriber_gender.blank?
      @s.push self.dataerrors.build(:message => "Subscriber's address is required", :created_user => self.created_user) if self.subscriber_address1.blank?
      @s.push self.dataerrors.build(:message => "Subscriber's city is required", :created_user => self.created_user) if self.subscriber_city.blank?
      @s.push self.dataerrors.build(:message => "Subscriber's state is required", :created_user => self.created_user) if self.subscriber_state.blank?
      @s.push self.dataerrors.build(:message => "Subscriber's zip is required", :created_user => self.created_user) if self.subscriber_zip.blank?      
      # 1/17/13 - Mark states that validatng the employer is not necessary
      #@s.push self.dataerrors.build(:message => "Employer's name is required", :created_user => self.created_user) if self.employer_name.blank?
      #@s.push self.dataerrors.build(:message => "Employer's address is required", :created_user => self.created_user) if self.employer_address1.blank?
      #@s.push self.dataerrors.build(:message => "Employer's city is required", :created_user => self.created_user) if self.employer_city.blank?
      #@s.push self.dataerrors.build(:message => "Employer's state is required", :created_user => self.created_user) if self.employer_state.blank?
      #@s.push self.dataerrors.build(:message => "Employer's zip is required", :created_user => self.created_user) if self.employer_zip.blank?
      #@s.push self.dataerrors.build(:message => "Employer's phone is required", :created_user => self.created_user) if self.employer_phone.blank?
      @s.push self.dataerrors.build(:message => "Insured's relationship to the subscriber is required", :created_user => self.created_user) if self.type_patient.blank?

      #if there are errors, save them to the dataerrors table and return false
      if @s.count > 0
        Dataerror.store(@s) 
        @state = false
      end
      #if the error counts changed, then update all insurance_bill
      if @original_count != @s.count
        self.insurance_billings.each { |billing| billing.validate_claim }
      end       

      return @state
    end
end
