class InsuranceBilling < ActiveRecord::Base

    belongs_to :insurance_session
    belongs_to :subscriber
    belongs_to :patient
    belongs_to :managed_care
    belongs_to :provider
    belongs_to :group
    belongs_to :insurance_company

    has_many :eobs, :dependent => :destroy
    has_many :dataerrors, :as => :dataerrorable, :dependent => :destroy

    has_many :iprocedures, :as => :iprocedureable, :dependent => :destroy
    has_many :codes_cpt, :through => :iprocedures
    accepts_nested_attributes_for :iprocedures, :allow_destroy => true

    has_many :idiagnostics, :as => :idiagable, :dependent => :destroy
    accepts_nested_attributes_for :idiagnostics, :allow_destroy => true

    # relationship for invoicing
    has_many :invoice_details, :as => :idetailable, :dependent => :destroy

    # paper trail versions
    has_paper_trail :class_name => 'InsuranceBillingVersion'

    #default scope hides records marked deleted
    default_scope where(:deleted => false)

    # allows the skipping of callbacks to save on database loads
    # use InsuranceBilling.skip_callbacks = true to set, or in update_attributes(..., :skip_callbacks => true)
    cattr_accessor :skip_callbacks

    before_validation :update_table_links, :unless => :skip_callbacks
    before_validation :update_charges, :unless => :skip_callbacks
    before_update :update_iprocedures, :unless => :skip_callbacks

    after_create :initialize_the_claim

    after_save :validate_data, :if => :editable_state?, :unless => :skip_callbacks
    after_save :update_session_finance, :if => :editable_state?, :unless => :skip_callbacks   # saves the related session record to force finance updates
    after_save :update_manage_care, :if => :editable_state?, :unless => :skip_callbacks       # updates managed care counts

    #after_save :validate_claim, :unless => :skip_callbacks  - valid_claim is caled from validate_data in insurance_session
    before_destroy :verify_record_deletable

    scope :initial, {:conditions => ["insurance_billings.status = ?", BillingFlow::INITIATE],  # initialized
          :include => [:group, :insurance_session, :patient, :provider, :subscriber=> :insurance_company],
          :order => "providers.last_name ASC, patients.last_name ASC, insurance_billings.dos ASC" }

    scope :pending,  {:conditions => ["insurance_billings.status >= ? and insurance_billings.status <= ?", BillingFlow::OVERRIDE, BillingFlow::READY ],  # pending submission
          :include => [:group, :insurance_session, :patient, :provider, :subscriber=> :insurance_company],
          :order => "providers.last_name ASC, patients.last_name ASC, insurance_billings.dos ASC" }

    # claim processed either edi or printing
    scope :processed, {
          :conditions => ["insurance_billings.status > ? and insurance_billings.status < ?", BillingFlow::READY, BillingFlow::PAID],
          :include => [:group, :insurance_session, :patient, :provider, :subscriber => :insurance_company],
          :order => "providers.last_name ASC, patients.last_name ASC, insurance_billings.dos ASC" }

    scope :aged_processed, lambda { |date| {
          :conditions => ["insurance_billings.status > ? and insurance_billings.status < ? and insurance_billings.claim_submitted < ?",
           BillingFlow::READY, BillingFlow::PAID, date],
          :include => [:group, :insurance_session, :patient, :provider, :subscriber=> :insurance_company],
          :order => "providers.last_name ASC, patients.last_name ASC, insurance_billings.dos ASC" }}


    scope :edi,          where("status = ?", BillingFlow::SUBMITTED )     # claim sent via edi
    scope :printed,      where("status = ?", BillingFlow::PRINTED )       # claim printed
    scope :ack,          where("status = ?", BillingFlow::ACKNOWLEDGED )  # claim received 999/277
    scope :pending_eob,  where("status > ? and status < ?", BillingFlow::READY, BillingFlow::ERRORS) # claim pending eob
    scope :errors,       where("status = ?", BillingFlow::ERRORS )        # claim sent and rejected or more info needed
    scope :paid,         where("status = ?", BillingFlow::PAID )          # eob received, needs to be reviewed for secondary processing
    scope :completed,    where("status >= ?", BillingFlow::CLOSED )        # eob received, claim is done

    #for pulling all claims that are billable to the client
    scope :billable,     :conditions => ["status >= ? and status <= ? and invoiced = ?", BillingFlow::ERRORS, BillingFlow::CLOSED_RESUBMIT, false]

    attr_accessible :status, :subscriber_id, :insurance_session_id, :dos, :managed_care_id,
                    :patient_id, :provider_id, :group_id, :insurance_company_id,
                    :insurance_billed, :claim_number, :claim_submitted, :dataerror, :dataerror_count,
                    :iprocedures_attributes, :idiagnostics_attributes, :secondary_status,
                    :invoiced, :invoice_id,
                    :override_user_id, :override_datetime,  # these 2 fields are set when the user elects to override the dataerrors and set claim to ready state
                    :created_user, :updated_user, :deleted,
                    :edi_status, :edi_transaction,
                    :skip_callbacks  # made accessible to allow tests to work

    attr_accessor   :edi_status, :edi_transaction   # used for setting all the details in insurance billing histories

    STATUS_SIZE = 20
    CLAIM_NUMBER = 50
    EDI_LIMIT = 25

    validates :status, :presence => true
    validates :claim_number, :length => { :maximum => CLAIM_NUMBER }, :allow_nil => true, :allow_blank => true

    #validate as mny of the *_id fields as we can.  cant validate the subscriber_id and insurance_compamny_id.
    #those records may not have been entered before the insurance_billing record is created.  those fileds are required before a claim can be submitted.
    validates :patient_id, :presence => true
    validates :insurance_session_id, :presence => true
    validates :provider_id, :presence => true
    validates :invoiced, :inclusion => {:in => [true, false]}

    validates :created_user, :presence => true
    validates :deleted, :inclusion => {:in => [true, false]}


    # return the processed claims that are waiting for an eob for a specific patient
    def self.processed_by_patient(id)
      self.find(:all,
        :conditions => ["(insurance_billings.status = ? or insurance_billings.status = ?) and insurance_sessions.patient_id = ?", BillingFlow::SUBMITTED, BillingFlow::PRINTED, id],
        :joins => [:insurance_session, :subscriber]
      )
    end

    # override the destory method to set the deleted boolean to true.
    def destroy
      run_callbacks :destroy do
        self.update_column(:deleted, true)
      end
    end

    #
    # verifys the record is deletable.  if the record has been submitted, then it is no longer deleteable
    # because the data has been sent outside of the system and needs to be trackable
    def verify_record_deletable
      BillingFlow::verify_record_deletable(self.status)
    end


    #
    # used to determine if the claim is still in the initiate or ready state
    # if it is, then there could be errors with the claim that needs to be updated
    # in the initate and ready state, the user can change fields
    def editable_state?
      BillingFlow::editable_state?(self.status)
    end


    # overrides the current status of the claim.  Stops the callbacks for validate_claim
    # the validate_claim will automatically set the status back to error for normal processing
    def override_status(user_id)
      #store the override in the history table
      @history = self.insurance_billing_histories.new(:status => BillingFlow::OVERRIDE, :status_date => DateTime.now,
                 :created_user => (self.updated_user.blank? ? self.created_user : self.updated_user))
      if @history.save
        errors.add :base, "Error creating the insurance billing history override record"
      end
      # this update attributes will also add a second history record for the ready state
      return self.update_attributes(:status => BillingFlow::OVERRIDE, :override_user_id => user_id, :override_datetime => DateTime.now, :skip_callbacks => true,
                  :updated_user => (self.updated_user.blank? ? self.created_user : self.updated_user))
    end


    def update_charges
      logger.info "Update Claim Charge: Insurance Billing ID: #{self.id}, Session ID: #{self.insurance_session_id}, Patient ID: #{self.patient_id}, Provider ID: #{self.provider_id}"
      @sum = 0.0
      self.iprocedures.each do |proc|
        logger.info "   CPT Code: #{proc.cpt_code}, Rate ID: #{proc.rate_id}, Override Rate: #{proc.rate_override}, Sessions: #{proc.sessions}, Units: #{proc.units}"
        # get the multiplier; could be units / session or default to 1
        if !proc.sessions.blank? && proc.sessions > 0
          multiplier = proc.sessions
        elsif !proc.units.blank? && proc.units > 0
          multiplier = proc.units
        else
          multiplier = 1
        end

        if !proc.rate_override.blank? && proc.rate_override > 0.0
           proc.total_charge = multiplier * proc.rate_override
           logger.info "   Override Rate: #{proc.rate_override}, Multiplier: #{multiplier}, Total Charge: #{proc.total_charge}"
        else
           rate = 0.00
           begin
             rec = Rate.unscoped.find(proc.rate_id) if proc.rate_id
             rate = rec.rate if !rec.blank?
           rescue
             # do nothing; rate was set to 0.00
           end
           proc.total_charge = multiplier * rate
           logger.info "   Rate: #{rate}, Multiplier: #{multiplier}, Total Charge: #{proc.total_charge}"
        end
        @sum += proc.total_charge ? proc.total_charge : 0.0
      end
      self.insurance_billed = @sum
      logger.info "Update Claim Charge; Insurance Billed: #{self.insurance_billed}"
      return true
    end

    #
    # Updates all the *_id fields linking to other tables
    # Called on a before_save to ensure the latest links are stored.
    #
    def update_table_links
      begin
        session = self.insurance_session
        self.dos = session.dos
        self.patient_id = session.patient_id
        self.provider_id = session.provider_id
        self.group_id = session.group_id
        #subscriber is a set field for each claim; dont update it here.
        self.insurance_company_id = self.subscriber.insurance_company_id if self.subscriber
      rescue
        errors.add :base, "updating table links failed."
        logger.info "Updated Table Links Failed: Insurance Billing ID: #{self.id}, Session ID: #{self.insurance_session_id}, Patient ID: #{self.patient_id}, Provider ID: #{self.provider_id}"
        return false
      end
      logger.info "Updated Table Links Success: Insurance Billing ID: #{self.id}, Session ID: #{self.insurance_session_id}, Patient ID: #{self.patient_id}, Provider ID: #{self.provider_id}"
      return true
    end


    #
    # update the associated iprocs updated_user field
    #
    def update_iprocedures
      self.iprocedures.each{|proc| proc.updated_user = self.updated_user}
    end


    #
    # saves the related session record to force a re-calc of the finances
    #
    def update_session_finance
      logger.info "Updated Session Finance: Insurance Billing ID: #{self.id}, Session ID: #{self.insurance_session_id}, Patient ID: #{self.patient_id}, Provider ID: #{self.provider_id}"
      # set the insurance session status
      @session = self.insurance_session
      #secondary status will be primary / secondary/ tertiary or other
      @session.status = self.secondary_status  #THIS STATEMENT IS RESETTING A CLOSD SESSION TO OPEN
      return self.insurance_session.save  # recalculates the charges with the callbacks
    end

    #
    # updates the counts in managed care
    #
    def update_manage_care
      if self.managed_care
        # check to make sure we have a managed care record
        logger.info "Managed Care Update: Insurance Billing ID: #{self.id}, Managed Care: #{self.managed_care_id}"
        return self.managed_care.save       # recalcultes the managed care session counts
      end
      logger.info "Managed Care Not Associated, Insurance Billing ID: #{self.id}"
      return true
    end


    #
    # Need to revert the claim to its prior state using insurance billing history
    # Deleting manually entered eobs is one example where this is called from
    def revert_to_previous_status
      @history = self.previous_version
      begin
        while @history.status == self.status
          @history = @history.previous
        end
        self.status = @history.status
      rescue
        self.status = BillingFlow::PAID
      end
    end


    #
    # creates the unique claim number for each claim
    # The claim number is created right after the inital record is saved
    # claim number is the unique id record from the database plus the system identifier plus the 6 digit date
    # create the initial history record
    def initialize_the_claim
      begin
        # use the id of the record for the unique claim record
        # if claim number already set, then we want to leave it
        systeminfo = SystemInfo.first
        if !systeminfo || systeminfo.system_claim_identifier.blank?
          raise "System Claim Identifier in SystemInfos is blank"
        end
        # generate the unique claim number
        claim_number ||= self.id.to_s + systeminfo.system_claim_identifier + Date.today.strftime("%y%m%d")
        self.update_column(:claim_number, claim_number)
      rescue
        errors.add :base, "Creating unique claim number failed"
        return false
      end
      return true
    end


    # check_data is a validation routine for the claim to ensure each session record is ready for submission
    # returns a message array of errors.  if no errors it returns an empty array.
    # each model checks the fields within itself for completeness.
    # insurance billing has the ties to all the various records for a claim and can check all relationships required.
    def validate_data
      logger.info "Validate Data: Insurance Billing ID: #{self.id}, Session ID: #{self.insurance_session_id}, Patient ID: #{self.patient_id}, Provider ID: #{self.provider_id}"
      begin
        # first remove any old errors from the table
        self.dataerrors.clear

        @s = []
        # check the necessary fields in the table
        # use the build method so the polymorphic reference is generated cleanly
        # the following to check should never be possible.  claims are always associated to a patient and session
        @s.push self.dataerrors.build(:message => "No Patient associated to claim; Delete this claim and create a new one", :created_user => self.created_user) if self.patient_id.blank?
        @s.push self.dataerrors.build(:message => "No session associated to claiml Delete this claim and create a new one", :created_user => self.created_user) if self.insurance_session_id.blank?
        # check for the relationships to other tables
        @s.push self.dataerrors.build(:message => "Subscriber record must be selected - Reselect the subscriber in the claim and re-save", :created_user => self.created_user) if self.subscriber_id.blank?
        @s.push self.dataerrors.build(:message => "No provider associated to claim", :created_user => self.created_user) if self.provider_id.blank?
        @s.push self.dataerrors.build(:message => "No insurance company associated to this claim", :created_user => self.created_user) if self.insurance_company_id.blank?

        # check the fields within insurance billing
        @s.push self.dataerrors.build(:message => "Insurance amount billed needs to be entered", :created_user => self.created_user) if self.insurance_billed.blank?
        @s.push self.dataerrors.build(:message => "Insurance amount billed is $0.00, it needs to be entered", :created_user => self.created_user) if self.insurance_billed <= 0

        @s.push self.dataerrors.build(:message => "Claim does not have a unique identifier. Delete this claim and create a new one.", :created_user => self.created_user) if self.claim_number.blank?

        # check the procedure and dignostic codes, must have one of each
        cpt = self.iprocedures
        @s.push self.dataerrors.build(:message => "At least one Procedure code must be entered", :created_user => self.created_user) if cpt.count == 0
        diag = self.idiagnostics
        @s.push self.dataerrors.build(:message => "At least one Diagnostic code must be entered", :created_user => self.created_user) if diag.count == 0
        # if there are errors, save them to the dataerrors table and return false
        if @s.count > 0
          Dataerror.store(@s)
          return false
        end
      rescue
        errors.add :base, "failed to validate insurance billing date"
        logger.info "Validate Data Failed"
        return false
      end
      # everything is good, return true
      logger.info "Validate Data Completed: Insurance Billing ID: #{self.id}"
      return true
    end


    #
    # validate_claim checkes all the related table entires for this claim to ensure it is accurat and ready for claim submission
    # if there are errors, the dataerror_count is update and the dataerror boolean is set to true
    # this routine is called by various other models when records are associated
    def validate_claim
      if self.editable_state?     # keep the editable_state? check here.  this method is called by other models when errors are cleared
        logger.info "Validate Claim: Insurance Billing ID: #{self.id}, Session ID: #{self.insurance_session_id}, Patient ID: #{self.patient_id}, Provider ID: #{self.provider_id}"
        # check the system info record
        @system_info = SystemInfo.first
        self.transaction do
          @count = @system_info == nil ? 1 : @system_info.dataerrors.count
          logger.info "   System Info: #{@count}"
          #check self for any errors
          #catching iprocedure and idiagnostic errors are captured in the self check
          @count += self.dataerrors.count
          logger.info "   Self: #{@count}"
          #check the session fr any errors
          @count += self.insurance_session.dataerrors.count
          logger.info "   Insurance Session: #{@count}"
          #check the patient
          @count += self.patient.dataerrors.count
          logger.info "   Patient: #{@count}"
          #check the provider and group, if there is a group.  also check the provider insurance
          @count += self.provider.dataerrors.count
          logger.info "   Provider: #{@count}"
          @count += self.group.dataerrors.count if !self.group.blank?
          logger.info "   Group: #{@count}"

          if self.subscriber
            @count +=  self.subscriber.dataerrors.count
            logger.info "   Subscriber: #{@count}"
            # insurance company also need to be verified
            @count += self.subscriber.insurance_company ? self.subscriber.insurance_company.dataerrors.count : 1
            logger.info "   Subscriber Insurance: #{@count}"
          else
            #add one for missing subscriber
            @count += 1
            logger.info "   Subscriber Missing: #{@count}"
          end
          #check the managed care record
          @count += self.managed_care.dataerrors.count if self.managed_care
          logger.info "   Managed Care: #{@count}"
          #check the insurance session errors counts for patient injury history, managed_care info and office info
          @count += self.insurance_session.patient_injury ? self.insurance_session.patient_injury.dataerrors.count : 0
          logger.info "   Patient Injury: #{@count}"
          @count += self.insurance_session.office ? self.insurance_session.office.dataerrors.count : 1
          logger.info "   Office: #{@count}"
        end  #end of transaction to get the counts
        self.transaction do
          # update the errors, error_count and status fields without validations
          if @count > 0
            self.update_column(:dataerror, true)
            self.update_column(:dataerror_count, @count)
            # if the claim has been overridden, then leave it for processing.
            if self.status != BillingFlow::INITIATE && self.status != BillingFlow::OVERRIDE
              self.update_column(:status, BillingFlow::ERRORS)
            end
          else
            self.update_column(:dataerror, false)
            self.update_column(:dataerror_count, 0)
            # dont reset status if already in ready or override state; dont create duplicate history record
            if self.status != BillingFlow::READY && self.status != BillingFlow::OVERRIDE
              #self.status_will_change
              self.update_column(:status, BillingFlow::READY)
            end
          end
        end
        logger.info "Validate Claim Completed: Insurance Billing ID: #{self.id}"
      end
      return true
    end


    #
    # clones the diagnostic codes from the supplied parent into self
    #
    def clone_iprocedures(parent)
      parent.iprocedures.each do |i|
        begin
          @rate = Rate.find(i.rate_id) if !i.rate_id.blank?
        rescue
          @rate = nil
        end

        if !i.rate_override.blank?
          @total_charge =  i.rate_override
        else
          #rate could have been deleted, so check to see if we find one.
          @total_charge = !@rate.blank? ? @rate.rate : 0.00
        end

        # if the rate is blank then set the rate_id to nil
        self.iprocedures.new(:cpt_code => i.cpt_code, :modifier1 => i.modifier1, :modifier2 => i.modifier2, :modifier3 => i.modifier3, :modifier4 => i.modifier4,
              :rate_id => (@rate.blank? ? nil : @rate.id),
              :rate_override => i.rate_override, :total_charge => @total_charge, :units => 0, :sessions => 0,
              :diag_pointer1 => i.diag_pointer1, :diag_pointer2 => i.diag_pointer2, :diag_pointer3 => i.diag_pointer3,
              :diag_pointer4 => i.diag_pointer4, :diag_pointer5 => i.diag_pointer5, :diag_pointer6 => i.diag_pointer6,
              :created_user => self.created_user)
      end
      self.save!
    end


    #
    # clones the diagnostics codes from the supplied parent into self
    #
    def clone_idiagnostics(parent)
      parent.idiagnostics.each do |i|
        self.idiagnostics.new(:icd9_code => i.icd9_code, :icd10_code => i.icd10_code, :dsm_code => i.dsm_code,
                              :dsm4_code => i.dsm4_code, :dsm5_code => i.dsm5_code, :created_user => self.created_user)
      end
      self.save!
    end

end
