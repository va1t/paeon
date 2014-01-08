class InsuranceSession < ActiveRecord::Base

    belongs_to :patient
    belongs_to :provider
    belongs_to :group
    belongs_to :patient_injury
    belongs_to :office
    belongs_to :billing_office, :class_name => 'Office'

    has_many :insurance_billings, :dependent => :destroy

    has_one :balance_bill_session, :dependent => :destroy, :conditions => ["balance_bill_sessions.status NOT IN ('Deleted')"]
    has_one :balance_bill, :through => :balance_bill_session

    has_many :notes, :as => :noteable, :dependent => :destroy
    has_many :dataerrors, :as => :dataerrorable, :dependent => :destroy

    # paper trail versions
    has_paper_trail :class_name => 'InsuranceSessionVersion'

    # allows the skipping of callbacks to save on database loads
    # this is used pricipall for testing, to isolate the callbacks
    # use InsuranceSession.skip_callbacks = true to set, or in update_attributes(..., :skip_callbacks => true)
    cattr_accessor :skip_callbacks

    #default scope hides records marked deleted
    default_scope where(:deleted => false)

    scope :opened, where("status < ?", SessionFlow::CLOSED )
    scope :primary, where("status = ?", SessionFlow::PRIMARY )
    scope :secondary, where("status = ?", SessionFlow::SECONDARY )
    scope :tertiary, where("status = ?", SessionFlow::TERTIARY )
    scope :other, where("status = ?", SessionFlow::OTHER )
    scope :balancebill, where("status = ?", SessionFlow::BALANCE )
    scope :closed, where("status = ?", SessionFlow::CLOSED )

    # session is in an open state, but no active claims
    #scope :no_claims, :conditions => ["(id not in (select insurance_session_id from insurance_billings where deleted = 0) && id not in (select insurance_session_id from balance_bills where deleted = 0)) and insurance_sessions.status < ?", SessionFlow::CLOSED]
    #scope :closed_claims, :conditions => ["(id in (select insurance_session_id from insurance_billings where deleted = 0 and status = ?) || id in (select insurance_session_id from balance_bills where deleted = 0 and status = ?))  and insurance_sessions.status < ?", BillingFlow::CLOSED, BalanceBillFlow::CLOSED, SessionFlow::CLOSED]
    # temporary scopes
    scope :no_claims, :conditions => ["(id not in (select insurance_session_id from insurance_billings where deleted = 0)) and insurance_sessions.status < ?", SessionFlow::CLOSED]
    scope :closed_claims, :conditions => ["(id in (select insurance_session_id from insurance_billings where deleted = 0 and status = ?))  and insurance_sessions.status < ?", BillingFlow::CLOSED, SessionFlow::CLOSED]

    before_validation :format_date, :unless => :skip_callbacks
    before_validation :update_session_finance, :unless => :skip_callbacks   # need to update finances before validation.  Validations check if session is closable.
    after_save :validate_data, :unless => :skip_callbacks
    before_destroy :verify_record_deleteable

    attr_accessible :patient_id, :group_id, :provider_id, :dos, :selector, :office_id,
                    :billing_office_id, :status, :patient_injury_id, :pos_code,
                    :charges_for_service, :copay_amount, :coinsurance_amount, :deductible_amount,
                    :waived_fee, :balance_owed, :patient_additional_payment, :interest_payment,
                    :bal_bill_paid_amount,
                    :unformatted_service_date, #for use in datepicker
                    :created_user, :updated_user, :deleted,
                    :skip_callbacks  # need to make this accessible for tests


    attr_accessor :unformatted_service_date

    # validate DOS is after the effective date
    # commented out the effective date check on 5/11/13 - dont always have the effective date
    # validate :is_after_effective_date

    validate :validate_record_closeable

    validates :dos, :presence => {:message => "- Date of Serivce is required."}
    validates :patient_id, :presence => true
    validates :provider_id, :presence => true

    validates :created_user, :presence => true
    validates :deleted, :inclusion => {:in => [true, false]}


    # override the destory method to set the deleted boolean to true.
    def destroy
      run_callbacks :destroy do
        self.update_column(:deleted, true)
      end
    end

    #
    # verifies that all insurance_billing and balance_bills records associated
    # are in either the initiated or ready state
    # if anything has been sent out the door, then the session cannot be deleted
    def verify_record_deleteable
      #verify all insurance_billing records are initiated or ready
      @insurance_billings = self.insurance_billings.all
      @insurance_billings.each do |billing|
        if billing.status > BillingFlow::READY
          errors.add :base, "Session not deletable.  An insurance claim has been submitted."
          return false
        end
      end
      #verify all balance bill record ia in initiated state
      @balance_bill_session = self.balance_bill_session
      if @balance_bill_session and @balance_bill_session.balance_bill_id? and @balance_bill_session.balance_bill.balance_bill_deleteable?
          errors.add :base, "Session not deletable.  A balance bill has been submitted."
          return false
      end

      return true
    end

    #
    # validates that all insurance_billing and balance_bills records associated
    # are in closed state and the balance_owed is zero
    def validate_record_closeable
      if self.status == SessionFlow::CLOSED
        #verify the balance due is zero
        if self.balance_owed > 0
          errors.add :base, "The session #{self.id} has an outstanding balance and cannot be closed."
          return false
        else
          #verify all insurance_billing records are closed; force them closed if not
          self.insurance_billings.each do |billing|
            billing.update_column(:status, BillingFlow::CLOSED) if billing.status < BillingFlow::CLOSED
          end
        end
        #verify all balance bill records are closed
        @balance_bill_session = self.balance_bill_session
        if @balance_bill_session && @balance_bill_session.balance_bill_id? && !@balance_bill_session.balance_bill.balance_status?(:closed)
            errors.add :base, "Session #{self.id} not closeable.  A balance bill is not closed."
            return false
        end
      end
      return true
    end

    #
    # reformat the date of service from m/d/y to y/m/d for sotring in db
    #
    def format_date
      begin
        if !self.unformatted_service_date.blank?
          self.dos = Date.strptime(self.unformatted_service_date, "%m/%d/%Y").to_time(:utc)
        end
      rescue
        errors.add :base, "Invalid Date"
      end
    end


    #
    # verify that all associated claims and balance bills are closed
    # if a claim or invoice is outstanding, then return an error.
    #
    def verify_session_state
      #check that all claims are closed
      self.insurance_billings.each do |claim|
        if claim.status < BillingFlow::CLOSED
          errors.add :base, "Claim or Balance Bill cannot be created. Existing claim has not been closed."
          return false
        end
      end
      #check that all balance bills are closed
      if self.balance_bill #&& self.balance_bill.status != BalanceBillFlow::CLOSED
        errors.add :base, "Claim or Balance Bill cannot be created. Existing balance bill has not been closed."
        return false
      end
      return true
    end


    # checks the date of service is entered and is after the effective date of the primary insurance
    def is_after_effective_date
      @subscriber = self.patient.subscribers.find(:first, :conditions => ["ins_priority = ?", Subscriber::INSURANCE_PRIORITY[0] ])

      if self.dos.blank?
        errors.add :base, "Date of Service cannot be blank"
      elsif @subscriber.blank?
        errors.add :base, "Primary Patient Insured record is required"
      elsif @subscriber.start_date.blank?
        errors.add :base, "Primary Patient Insured effective date is required"
      elsif self.dos < @subscriber.start_date
        errors.add :base, "Date of Service is before the primary insurance start date."
      end
    end


    def update_session_finance
      # total charges are the sum of the first insurance billing
      # all the cpt codes with either rates or override rates summed equals the total charges
      # once a claim is submitted, the charges in the first claim is the total charges
      @ins_paid = 0
      @bal_paid = 0
      @allowed_amount = 0
      @billing = self.insurance_billings.first
      @coinsurance_amount = 0
      @deductible_amount = 0
      @copay_amount = 0

      logger.info "Update Session Finance #{self.id}, DOS: #{self.dos}"
      # get the total charge for service
      if !@billing.blank?
        self.charges_for_service = @billing.insurance_billed ? @billing.insurance_billed : 0 #add the lab costs
      elsif !self.balance_bill_session.blank?  # if no insurance claim, then the balance bill is the total amount
        self.charges_for_service = self.balance_bill_session.total_amount ? self.balance_bill_session.total_amount : 0  # accounts for null field
      else
        self.charges_for_service = 0  #default to zero; when blank records are created and nothing has been entered
      end

      # go through each claim for the session, sum up the amount insurance paid
      self.insurance_billings.each do |billing|
        # go through each eob for the claim
        billing.eobs.each do |eob|
          @ins_paid += eob.payment_amount

          # look for the allowed amount, if the allowed amount is not already set.
          # allowed amount should be set when the first eob comes back on the first claim.
          eob.eob_details.each do |detail|
            @allowed_amount = detail.allowed_amount if (!detail.allowed_amount.blank? && @allowed_amount == 0)
            @copay_amount = detail.copay_amount if (!detail.copay_amount.blank? && @copay_amount == 0)
            @coinsurance_amount += detail.coinsurance_amount if !detail.coinsurance_amount.blank?
            @deductible_amount += detail.deductible_amount if !detail.deductible_amount.blank?
          end
        end
      end

      # sum up the balance bill paid; only if the balance bill has been closed
      if self.balance_bill_session && !self.balance_bill_session.balance_bill_id.blank?
        @balance = self.balance_bill_session.balance_bill
        @bal_paid = self.balance_bill_session.total_amount if @balance.balance_status?(:closed)
        self.bal_bill_paid_amount = @bal_paid
      end

      # set the ins paid and allowed amounts
      self.ins_paid_amount = @ins_paid
      self.ins_allowed_amount = @allowed_amount
      self.coinsurance_amount = @coinsurance_amount
      self.deductible_amount = @deductible_amount
      self.copay_amount ||= @copay_amount

      #calculate the balance owed
      # the conditionals below handle null fields in the database
      additional_payment = self.patient_additional_payment ? self.patient_additional_payment : 0
      waived_fee = self.waived_fee ? self.waived_fee : 0

      # calculate the balance owed
      # there are 2 ways to calculate dependent upon the insurance if it is in/out network and if an eob had an allowed amount
      if in_network? && @allowed_amount > 0
        # calculate the balance owed off of the allowed amount
        self.balance_owed = @allowed_amount - @ins_paid - @bal_paid - additional_payment
      else
        # no allowed amount found on eobs from insurance companies, so calculate the balance owed.
        self.balance_owed = (self.charges_for_service == 0) ? 0 : (self.charges_for_service - additional_payment - @ins_paid - @bal_paid)
      end
      # there is a waived fee, so the waived fee = balance owed and balance owed should be 0
      if waived_fee != 0
        self.waived_fee = self.balance_owed
        self.balance_owed = 0.0
      end
      logger.info "Update Session Finance Completed: Charges: #{self.charges_for_service}, Balance owed: #{self.balance_owed}, Waived: #{self.waived_fee}, Ins Paid: #{self.ins_paid_amount}, Ins Allowed: #{self.ins_allowed_amount}, Bal Bill Paid: #{self.bal_bill_paid_amount}"
      return true
    end


    #
    # look up the validation record for the provider/group and subscriber
    # return true if in network
    def in_network?
      begin
        if self.selector == Selector::GROUP
          object = PatientsGroup.where("patient_id = ? and group_id = ?", self.patient_id, self.group_id).first
        else
          object = PatientsProvider.where("patient_id = ? and provider_id = ?", self.patient_id, self.provider_id).first
        end
        if self.insurance_billings
          subscriber = self.insurance_billings.first.subscriber_id
          subscriber_valid = object.subscriber_valids.where("subscriber_id = ?", subscriber).first
        else
          # there are no insurance billing records, so we cant find a subscriber to use
          # traeat as out of network
          return false
        end
      rescue
        # one of the supporting records had an issue.  So treat it as out of network.
        return false
      end
      # there was no validation record so treat as out of network
      return false if subscriber_valid.blank?
      return subscriber_valid.in_network == SubscriberValid::IN_NETWORK
    end



    # check_data is a validation routine for the claim to ensure each session record is ready for submission
    # returns a message array of errors.  if no errors it returns an empty array.
    # each model checks the fields within itself for completeness.
    # insurance billing has the ties to all the various records for a claim and can check all relationships required.
    def validate_data
      #store the original error count, if there is a chnage to the count, then we want to update all associated insurance_billings and balance_bills
      @original_count = self.dataerrors.count
      #first remove any old errors from the table
      self.dataerrors.clear

      @s = []
      # check the necessary fields in the table
      # use the build method so the polymorphic reference is generated cleanly
      # check for the relationships t other tables
      @s.push self.dataerrors.build(:message => "Date of Service must be entered", :created_user => self.created_user) if self.dos.blank?
      @s.push self.dataerrors.build(:message => "Patient is not associated to this session. Delete this session and create a new one.", :created_user => self.created_user) if self.patient_id.blank?
      @s.push self.dataerrors.build(:message => "Provider needs to be selected", :created_user => self.created_user) if self.provider_id.blank?
      @s.push self.dataerrors.build(:message => "Group needs to be selected", :created_user => self.created_user) if self.group_id.blank? && self.selector == Selector::GROUP
      @s.push self.dataerrors.build(:message => "Office where service rendered is required to be selected", :created_user => self.created_user) if self.office_id.blank?
      @s.push self.dataerrors.build(:message => "Billing Office is required to be selected", :created_user => self.created_user) if self.billing_office_id.blank?
      # patient injury history and managed care are not required for all sessions and/or cliams.  So cant check for them.

      # check the fields within session billing
      @s.push self.dataerrors.build(:message => "Patient copay needs to be entered", :created_user => self.created_user) if self.copay_amount.blank?
      @s.push self.dataerrors.build(:message => "Charge for Service needs to be entered", :created_user => self.created_user) if self.charges_for_service.blank?
      @s.push self.dataerrors.build(:message => "Point of Sevice code is required", :created_user => self.created_user) if self.pos_code.blank?

      #if there are errors, save them to the dataerrors table and return false
      Dataerror.store(@s) if @s.count > 0

      # if the error counts changed, then update all insurance_bill & balance bills
      # always trigger the updates below so that the polymorphic records that mey have had errors are cleared
      self.insurance_billings.each { |billing| billing.validate_claim }
      self.balance_bill.validate_balance_bill if self.balance_bill

      return @s.count == 0
    end

  # returns true if the selector == Group, else returns false
  def group?
    return self.selector == Selector::GROUP
  end

  # returns true if selector == Provider, else returns false
  def provider?
    return self.selector == Selector::PROVIDER
  end

  #
  # Update the status of the session when there is a sondary / tertiary / other claim
  #
  def set_status_secondary(login_name)
    if self.status == SessionFlow::PRIMARY
       self.status = SessionFlow::SECONDARY
    elsif self.status == SessionFlow::SECONDARY
       self.status = SessionFlow::TERTIARY
    elsif self.status == SessionFlow::TERTIARY
       self.status = SessionFlow::OTHER
    end
    self.updated_user = login_name
    self.save!
  end

    #
    # Need to revert the session to its prior state
    #
    def revert_to_previous_status
      # if balance bill, then set session to Bal bill
      if self.balance_bill
        self.status = SessionFlow::BALANCE
      else
        # use the last claim's secondary status for the session status
        secondary_status = self.insurance_billings.last.secondary_status
        self.status = secondary_status
      end
    end

  def set_status(status)
    self.update_column(:status, status)
  end
end
