#
#
# balance bill state module for handling state machine for balance bills,
# include this file in the balance bill model for use.
#
# Model includes a field  :string, :balance_state, :limit => 25
# do not add :balance_state to attr_accessible. :balance_state field can only be updated through this module
#
#
module BalanceBillStatus

  def self.included(base)
    base.state_machine :balance_status, :initial => :initiated do

      #
      # define all states with intrinsic value
      #
      state :initiated,        :value => 'Initiated'           # balance bill has been initiated, but not sent to patient
      state :ready,            :value => 'Ready'               # balance bill is ready to be sent to the client
      state :patient_invoiced, :value => 'Patient Invoiced'    # balance bill has been sent to the patient
      state :partial_payment,  :value => 'Partial Payment'     # balance is remaining after patient sent payment
      state :paid_in_full,     :value => 'Paid in Full'        # balance paid in full
      state :first_notice,     :value => "Notice Sent"         # sent first late notice
      state :second_notice,    :value => "Second Notice Sent"  # sent second late notice
      state :third_notice,     :value => "Third Notice Sent"   # sent third late notice
      state :collections,      :value => 'Collection'          # balance bill has been sent to collection agency
      state :waived,           :value => 'Waived'              # balance bill was waived
      state :closed,           :value => 'Closed'              # balance and claim reviewed and marked closed
      state :nill_field,       :value => nil                   # for adding status to existing records, allow a null status so rake task can set it to default

      #
      # define events and transitions
      #

      # initializes record to the begining state.
      # used primarliy for setting existing records to the initial state
      event :init_balance_status do
        transition all => :initiated
      end


      # the data_validated? method is called to verify the balance bill is ready to be sent
      # if all the fields are validated, then the state is set to ready
      event :validate do
        if :data_validated?
          transition [:initiated, :ready] => :ready
        else
          transition [:initiated, :ready] => :initiated
        end
      end


      # the balance bill is printed for mailing to the patient
      event :mailed do
        transition :ready            => :patient_invoiced,
                   :patient_invoiced => :first_notice,
                   :first_notice     => :second_notice,
                   :second_notice    => :third_notice,
                   :third_notice     => :collections,
                   :collections      => :collections,
                   :partial_payment  => :patient_invoiced
      end


      # receieved a payment, if paid in full, mark the balance bill as paid.
      # if the balance bill was in collections, and received payment, updated status to :paid or :balance
      # if not paid in full then status is :balance
      event :paid do
        transition [:ready, :patient_invoiced, :partial_payment, :first_notice, :second_notice, :third_notice, :collections] => :paid_in_full
      end

      event :partial_paid do
        transition [:ready, :patient_invoiced, :partial_payment, :first_notice, :second_notice, :third_notice, :collections] => :partial_payment
      end

      before_transition :on => :waive, :do => :waive_balance

      # the remaining balance is being waived
      # any state except for paid, waived can be waived.
      event :waive do
        transition all - [:paid_in_full, :waived] => :waived
      end

      before_transition :on => :close, :do => :close_balance
      after_transition  :on => :close, :do => :close_sessions

      # only paid or waived balance bills can be closed
      event :close do
        transition [:paid_in_full, :waived, :closed] => :closed
      end

      #
      # define after_failure callbacks
      #
      after_failure :on => :init_balance_status do |cs, transition|
        Rails.logger.info "BalanceBillStatus: init_balance_status failed. Record is not in an initiated; Transition: #{transition.inspect}, Record: #{cs.inspect}"
        raise StandardError, "init_balance_status failed. Record is not in an initiated"
      end

      after_failure :on => :validate do |cs, transition|
        Rails.logger.info "BalanceBillStatus: Record is not in an initiated or ready state; Transition: #{transition.inspect}, Record: #{cs.inspect}"
        raise StandardError, "Record is not in an initiated or ready state"
      end

      after_failure :on => :mailed do |cs, transition|
        Rails.logger.info "BalanceBillStatus: Record is not ready to be mailed or payments have been received; Transition: #{transition.inspect}, Record: #{cs.inspect}"
        raise StandardError, "Record is not ready to be mailed or payments have been received"
      end

      after_failure :on => [:paid, :partial_paid] do |cs, transition|
        Rails.logger.info "BalanceBillStatus: Record has not been invoiced or has been waived; Transition: #{transition.inspect}, Record: #{cs.inspect}"
        raise StandardError, "Record has not been invoiced or has been waived; Transition: #{transition.inspect}, Record: #{cs.inspect}"
      end

      after_failure :on => :waive do |cs, transition|
        Rails.logger.info "BalanceBillStatus: Record has been paid, waived or closed; Transition: #{transition.inspect}, Record: #{cs.inspect}"
        raise StandardError, "Record has been paid, waived or closed"
      end

      after_failure :on => :close do |cs, transition|
        Rails.logger.info "BalanceBillStatus: Record is not paid in full or waived; Transition: #{transition.inspect}, Record: #{cs.inspect}"
        raise StandardError, "Record is not paid in full or waived"
      end

    end
  end


  #
  # common methods available to models
  #

  #
  # balance bills can be deleted only if they are in initiate, ready of error state
  # after the balance bill is invoiced, it cannot be deleted
  def balance_bill_deleteable?
    !self.balance_status?(:closed)
  end

  #
  # returns true if the balance bill is in a waivable state
  # balance bill is not in paid_in_full, waived or closed status
  def waiveable?
    self.balance_status?(:initiated) || self.balance_status?(:ready) || self.balance_status?(:partial_payment) || self.balance_status?(:patient_invoiced) || self.balance_status?(:first_notice) || self.balance_status?(:second_notice) || self.balance_status?(:third_notice) || self.balance_status?(:collections)
  end

  #
  # returns true if the balance bill has an outstanding balance due
  # balance bill is in ready, invoiced, 1st, 2nd 3rd notice, collections or partial_payment status
  def balance_owed?
    self.balance_status?(:ready) || self.balance_status?(:partial_payment) || self.balance_status?(:patient_invoiced) || self.balance_status?(:first_notice) || self.balance_status?(:second_notice) || self.balance_status?(:third_notice) || self.balance_status?(:collections)
  end

  #
  # if the balance bill is in the intiated or ready state, then the balance bill can be editted
  #
  def editable?
    self.balance_status?(:initiated) || self.balance_status?(:ready)
  end

  #
  # returns true if the balance bill has been sent to the patient
  # balance bill in in invoiced, 1st, 2nd 3rd notice, collections or partial_payment status
  def invoice_sent?
    self.balance_status?(:partial_payment) || self.balance_status?(:patient_invoiced) || self.balance_status?(:first_notice) || self.balance_status?(:second_notice) || self.balance_status?(:third_notice) || self.balance_status?(:collections)
  end

  #
  # check to see if a payment was made and the current status is either
  # :partial_payment or :paid_in_full.  If the status has move beyond then it is not current
  #
  def payment_made_current?
    (self.balance_status?(:partial_payment) || self.balance_status?(:paid_in_full)) && self.balance_bill_payments
  end

  #
  # determine if a payment was made at all for the balance bill
  #
  def payment_made?
    self.balance_bill_payments
  end

  #
  # sum up all payments; if outstanding balance then record partial
  # otheriwse mark as paid in full
  def record_payment
    #sum up all the payments
    total_paid = 0
    self.balance_bill_payments.each do |p|
      total_paid += p.payment_amount
    end
    self.balance_owed = self.total_amount - total_paid
    self.payment_amount = total_paid
    # if there is a balance, then mark the balance bill as partial paid
    if self.total_amount > total_paid
      self.partial_paid
    else
      # asl long as the balance bill is not ready for closure, then mark it paid in full
      self.paid if !self.closeable?
    end
  end


  #
  # returns true is closable.  Record must be in :padi_in_full or :waived to be closeable
  #
  def closeable?
    self.balance_status?(:paid_in_full) || self.balance_status?(:waived) || self.balance_status?(:closed)
  end

  #
  # waive the balance
  #
  def waive_balance
    self.waived_date =  Date.today
    self.waived_amount = self.balance_owed
    self.balance_owed = 0.00
  end


  #
  # set the closed_date
  #
  def close_balance
    self.closed_date = Date.today
  end


  #
  # loop through all the balance_bill_sessions and close the session
  # apply the amounts paid to the sessions; if waived, then waive and close the sessions
  # the balance bill entry might not cover the remaining balance for the session
  # have to look at the session and the balance bill entry
  def close_sessions
    remaining = self.payment_amount
    # loop through the sessions; update the paid portion of the balance bill
    self.balance_bill_sessions.each do |bb_session|
      session = bb_session.insurance_session
      # calculate the amount to apply to this session
      amt_to_apply = remaining < bb_session.total_amount ? remaining : bb_session.total_amount
      # calculate the waived fee
      waived_fee = session.balance_owed != amt_to_apply ? (session.balance_owed - amt_to_apply) : 0.00
      session.update_attributes(:bal_bill_paid_amount => amt_to_apply, :balance_owed => "0.00", :waived_fee => waived_fee, :updated_user => self.updated_user)
      # do 2 saves until state machine can be implemented
      if !session.update_attributes(:status => SessionFlow::CLOSED)
        puts session.errors.inspect
      end
      remaining -= amt_to_apply
    end
  end

  #
  # validate the data has certain fields, otherise set an error.
  #
  def data_validated?
    #store the original error count, if there is a chnage to the count, then we want to update all associated insurance_billings and balance_bills
    @original_count = self.dataerrors.count
    #first remove any old errors from the table
    self.dataerrors.clear
    @s = []
    # check the necessary fields in the table
    # use the build method so the polymorphic reference is generated cleanly
    # check for the relationships t other tables
    @s.push self.dataerrors.build(:message => "An invoice date must be entered", :created_user => self.created_user) if self.invoice_date.blank?
    @s.push self.dataerrors.build(:message => "Patient is not associated to this Balance Bill. Delete this balance bill and create a new one.", :created_user => self.created_user) if self.patient_id.blank?

    # if adjustment amount > 0 then must have description
    @s.push self.dataerrors.build(:message => "An adjustment description is required with the adjustment amount.", :created_user => self.created_user) if ( self.adjustment_amount > 0 && self.adjustment_description.blank? )

    # must have at least one balance bill session record
    @s.push self.dataerrors.build(:message => "At least one session charge is required", :created_user => self.created_user) if self.balance_bill_sessions.count == 0

    # total_amount must be > 0
    @s.push self.dataerrors.build(:message => "The total amount for balance bill must be greater than 0", :created_user => self.created_user) if (self.total_amount.blank? || self.total_amount <= 0)

    #if there are errors, save them to the dataerrors table and return false
    Dataerror.store(@s) if @s.count > 0
    return @s.count == 0
  end

end
