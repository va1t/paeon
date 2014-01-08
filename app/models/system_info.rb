class SystemInfo < ActiveRecord::Base

    has_many :dataerrors, :as => :dataerrorable, :dependent => :destroy

    #default scope hides records marked deleted
    default_scope where(:deleted => false)

    after_save :validate_data

    attr_accessible :organization_name, :first_name, :last_name,
                    :ein_number, :ssn_number, :email, :work_phone, :fax_phone,
                    :address1, :address2, :city, :state, :zip, :system_claim_identifier,
                    :created_user, :updated_user, :deleted

    MAX_SYS_LENGTH = 100

    validates :organization_name, :length => {:maximum => MAX_SYS_LENGTH }, :allow_nil => true, :allow_blank => true
    validates :first_name, :length => {:maximum => STRING_LRG_LENGTH }, :allow_nil => true, :allow_blank => true
    validates :last_name,  :length => {:maximum => STRING_LRG_LENGTH }, :allow_nil => true, :allow_blank => true

    validates :ein_number, :length => {:maximum => SSN_LENGTH }, :allow_nil => true, :allow_blank => true
    validates :ssn_number, :length => {:maximum => SSN_LENGTH }, :allow_nil => true, :allow_blank => true

    validates :address1, :length => {:maximum => STRING_LRG_LENGTH }, :allow_nil => true, :allow_blank => true
    validates :address2, :length => {:maximum => STRING_LRG_LENGTH }, :allow_nil => true, :allow_blank => true
    validates :city,     :length => {:maximum => STRING_MED_LENGTH }, :allow_nil => true, :allow_blank => true
    validates :state,    :length => {:maximum => STRING_SML_LENGTH }, :allow_nil => true, :allow_blank => true
    validates :zip,      :length => {:maximum => ZIP_MAX_LENGTH }, :allow_nil => true, :allow_blank => true

    validates :work_phone, :length => {:maximum => PHONE_MAX_LENGTH }, :allow_nil => true, :allow_blank => true
    validates :fax_phone,  :length => {:maximum => PHONE_MAX_LENGTH }, :allow_nil => true, :allow_blank => true
    validates :email,      :length => {:maximum => MAX_SYS_LENGTH }, :allow_nil => true, :allow_blank => true

    validates :deleted, :inclusion => {:in => [true, false]}
    validates :created_user, :presence => true


    # override the destory method to set the deleted boolean to true.
    def destroy
      run_callbacks :destroy do
        self.update_column(:deleted, true)
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
      @s.push self.dataerrors.build(:message => "Organization name is required.", :created_user => self.created_user) if self.organization_name.blank?
      @s.push self.dataerrors.build(:message => "Contact's first name is required", :created_user => self.created_user) if self.first_name.blank?
      @s.push self.dataerrors.build(:message => "Contact's last name is required", :created_user => self.created_user) if self.last_name.blank?
      @s.push self.dataerrors.build(:message => "Either the EIN or SSN number used for billing needs to be provided",
                                    :created_user => self.created_user) if self.ein_number.blank? && self.ssn_number.blank?
      @s.push self.dataerrors.build(:message => "Primary office phone number is required", :created_user => self.created_user)    if self.work_phone.blank?
      @s.push self.dataerrors.build(:message => "Address is required", :created_user => self.created_user) if self.address1.blank?
      @s.push self.dataerrors.build(:message => "City is required", :created_user => self.created_user) if self.city.blank?
      @s.push self.dataerrors.build(:message => "State is required", :created_user => self.created_user) if self.state.blank?
      @s.push self.dataerrors.build(:message => "Zip is required", :created_user => self.created_user) if self.zip.blank?

      #if there are errors, save them to the dataerrors table and return false
      if @s.count > 0
        Dataerror.store(@s)
        @state = false
      end
      # if the error counts changed, then update all insurance_bill & balance bills
      # this will hit every insurance_billing and balance_billing record
      # looping through this section of code should not be normal when the system has been running
      if @original_count != @s.count
        @insurance_billings = InsuranceBilling.all
        @balance_bills = BalanceBill.all
        self.transaction do
          @insurance_billings.each { |billing| billing.validate_claim if billing.editable_state? }
          @balance_bills.each { |balance| balance.validate_balance_bill if balance.editable_state? }
        end
      end

      return @state
    end

end
