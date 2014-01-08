#
#
# invoice state module for handling state machine for balance bills,
# include this file in the balance bill model for use.
#
# Model includes a field  :string, :balance_state, :limit => 25
# do not add :balance_state to attr_accessible. :balance_state field can only be updated through this module
#
#
module InvoiceStatus

  def self.included(base)
    base.state_machine :invoice_status, :initial => :initiated do

      #
      # define all states with intrinsic value
      #
      state :initiated,        :value => 'Initiated'           # invoice has been initiated, but not sent to patient
      state :ready,            :value => 'Ready'               # invoice is ready to be sent to the client
      state :provier_invoiced, :value => 'Provider Invoiced'   # invoice has been sent to the patient
      state :partial_payment,  :value => 'Partial Payment'     # balance is remaining after patient sent payment
      state :paid_in_full,     :value => 'Paid in Full'        # balance paid in full
      state :first_notice,     :value => "Notice Sent"         # sent first late notice
      state :second_notice,    :value => "Second Notice Sent"  # sent second late notice
      state :third_notice,     :value => "Third Notice Sent"   # sent third late notice
      state :collections,      :value => 'Collection'          # invoice has been sent to collection agency
      state :waived,           :value => 'Waived'              # invoice was waived
      state :closed,           :value => 'Closed'              # balance and claim reviewed and marked closed
      state :nill_field,       :value => nil                   # for adding status to existing records, allow a null status so rake task can set it to default

      #
      # define events and transitions
      #

      # initializes record to the begining state.
      # used primarliy for setting existing records to the initial state
      event :init_invoice_status do
        transition all => :initiated
      end

      # the data_validated? method is called to verify the invoice is ready to be sent
      # if all the fields are validated, then the state is set to ready
      event :validate do
        if :data_validated?
          transition [:initiated, :ready] => :ready
        else
          transition [:initiated, :ready] => :initiated
        end
      end

      before_transition :on => [:validate, :waive], :do => :calculate_invoice

      # the balance bill is printed for mailing to the patient
      event :mailed do
        transition :ready             => :provider_invoiced,
                   :provider_invoiced => :first_notice,
                   :first_notice      => :second_notice,
                   :second_notice     => :third_notice,
                   :third_notice      => :collections,
                   :partial_payment   => :provider_invoiced
      end


      # receieved a payment, if paid in full, mark the invoce as paid.
      # if the invoice was in collections, and received payment, updated status to :paid or :balance
      # if not paid in full then status is :balance
      event :paid do
          transition [:provider_invoiced, :partial_payment, :first_notice, :second_notice, :third_notice, :collections] => :paid_in_full
      end

      event :partial_paid do
          transition [:provider_invoiced, :partial_payment, :first_notice, :second_notice, :third_notice, :collections] => :partial_payment
      end

      before_transition :on => :waive, :do => :waive_balance

      # the remaining balance is being waived
      # any state except for paid, waived and closed can be waived.
      event :waive do
        transition all - [:paid_in_full, :waived, :closed] => :waived
      end


      # only paid or waived balance bills can be closed
      event :close do
        transition [:paid_in_full, :waived] => :closed
      end


      #
      # define after_failure callbacks
      #
      after_failure :on => :init_invoice_status do |cs, transition|
        Rails.logger.info "InvoiceStatus: init_invoice_status failed. Record is not in an initiated; Transition: #{transition.inspect}, Record: #{cs.inspect}"
        raise StandardError, "init_invoice_status failed. Record is not in an initiated"
      end

      after_failure :on => :validate do |cs, transition|
        Rails.logger.info "InvoiceStatus: Record is not in an initiated or ready state; Transition: #{transition.inspect}, Record: #{cs.inspect}"
        raise StandardError, "Record is not in an initiated or ready state"
      end

      after_failure :on => :mailed do |cs, transition|
        Rails.logger.info "InvoiceStatus: Record is not ready to be mailed or payments have been received; Transition: #{transition.inspect}, Record: #{cs.inspect}"
        raise StandardError, "Record is not ready to be mailed or payments have been received"
      end

      after_failure :on => [:paid, :partial_paid] do |cs, transition|
        Rails.logger.info "InvoiceStatus: Record has not been invoiced or has been waived; Transition: #{transition.inspect}, Record: #{cs.inspect}"
        raise StandardError, "Record has not been invoiced or has been waived"
      end

      after_failure :on => :waive do |cs, transition|
        Rails.logger.info "InvoiceStatus: Record has been paid, waived or closed; Transition: #{transition.inspect}, Record: #{cs.inspect}"
        raise StandardError, "Record has been paid, waived or closed"
      end

      after_failure :on => :close do |cs, transition|
        Rails.logger.info "InvoiceStatus: Record is not paid in full or waived; Transition: #{transition.inspect}, Record: #{cs.inspect}"
        raise StandardError, "Record is not paid in full or waived"
      end

    end
  end


  #
  # common methods available to models
  #

  #
  # invoices can be deleted only if they are in initiate, ready of error state
  # after the invoice is sent, it cannot be deleted
  def invoice_deleteable?
    self.invoice_status?(:initiated) || self.invoice_status?(:ready)
  end

  #
  # returns true if the balance bill is in a waivable state
  # invoice is not in paid_in_full, waived or closed status
  def waiveable?
    self.invoice_status?(:initiated) || self.invoice_status?(:ready) || self.invoice_status?(:partial_payment) || self.invoice_status?(:provider_invoiced) || self.invoice_status?(:first_notice) || self.invoice_status?(:second_notice) || self.invoice_status?(:third_notice) || self.invoice_status?(:collections)
  end

  #
  # if the balance bill is in the intiated or ready state, then the balance bill can be editted
  #
  def editable?
    self.invoice_status?(:initiated) || self.invoice_status?(:ready)
  end

  #
  # returns true if the balance bill has an outstanding balance due
  # invoice is in ready, invoiced, 1st, 2nd 3rd notice, collections or partial_payment status
  def balance_owed?
    self.invoice_status?(:ready) || self.invoice_status?(:partial_payment) || self.invoice_status?(:provider_invoiced) || self.invoice_status?(:first_notice) || self.invoice_status?(:second_notice) || self.invoice_status?(:third_notice) || self.invoice_status?(:collections)
  end

  #
  # returns true if the balance bill has been sent to the patient
  # invoice in in invoiced, 1st, 2nd 3rd notice, collections or partial_payment status
  def invoice_sent?
    self.invoice_status?(:partial_payment) || self.invoice_status?(:provider_invoiced) || self.invoice_status?(:first_notice) || self.invoice_status?(:second_notice) || self.invoice_status?(:third_notice) || self.invoice_status?(:collections)
  end
    #
  # check to see if a payment was made and the current status is either
  # :partial_payment or :paid_in_full.  If the status has move beyond then it is not current
  #

  def payment_made_current?
    (self.invoice_status?(:partial_payment) || self.invoice_status?(:paid_in_full)) && self.invoice_payments
  end

  #
  # determine if a payment was made at all for the balance bill
  #
  def payment_made?
    self.invoice_payments
  end

  #
  # returns true is closable.  Record must be in :padi_in_full or :waived to be closeable
  #
  def closeable?
    self.invoice_status?(:paid_in_full) || self.invoice_status?(:waived) || self.invoice_status?(:closed)
  end


  def waive_balance
    self.waived_date =  Date.today
    self.waived_amount = self.balance_owed_amount
    self.balance_owed_amount = 0.00
  end


  #
  # validate the data has certain fields, otherise set an error.
  #
  def data_validated?
    #store the original error count, if there is a change to the count, then we want to update all associated insurance_billings and balance_bills
    @original_count = self.dataerrors.count
    #first remove any old errors from the table
    self.dataerrors.clear
    @s = []
    # check the necessary fields in the table
    # use the build method so the polymorphic reference is generated cleanly
    # check for the relationships t other tables
    @s.push self.dataerrors.build(:message => "Created Date cannot be blank", :created_user => self.created_user)               if self.created_date.blank?
    @s.push self.dataerrors.build(:message => "Total Amount needs to be a positivie value", :created_user => self.created_user) if self.total_invoice_amount.blank? || self.total_invoice_amount <= 0
    @s.push self.dataerrors.build(:message => "Balance Owed must be a positive value", :created_user => self.created_user)      if self.balance_owed_amount.blank? || self.balance_owed_amount <= 0

    # subtotals
    @s.push self.dataerrors.build(:message => "Subtotal for claims cannot be blank", :created_user => self.created_user)                   if self.subtotal_claims.blank?
    @s.push self.dataerrors.build(:message => "Subtotal for balance bills cannot be blank", :created_user => self.created_user)            if self.subtotal_balance.blank?
    @s.push self.dataerrors.build(:message => "Subtotal for setup fees cannot be blank", :created_user => self.created_user)               if self.subtotal_setup.blank?
    @s.push self.dataerrors.build(:message => "Subtotal for coordination of benefits cannot be blank", :created_user => self.created_user) if self.subtotal_cob.blank?
    @s.push self.dataerrors.build(:message => "Subtotal for denied claims cannot be blank", :created_user => self.created_user)            if self.subtotal_denied.blank?
    @s.push self.dataerrors.build(:message => "Subtotal for administration fees cannot be blank", :created_user => self.created_user)      if self.subtotal_admin.blank?
    @s.push self.dataerrors.build(:message => "Subtotal for discovery fees cannot be blank", :created_user => self.created_user)           if self.subtotal_discovery.blank?

    #if there are errors, save them to the dataerrors table and return false
    Dataerror.store(@s) if @s.count > 0
    return @s.count == 0
  end


end
