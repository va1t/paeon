class BalanceBill < ActiveRecord::Base
  #
  # includes
  #
  include CommonStatus
  include BalanceBillStatus

  #
  # model associations
  #
  belongs_to :patient
  belongs_to :provider
  belongs_to :invoice

  has_many :balance_bill_sessions, :dependent => :nullify, :order => :dos, :conditions => ["balance_bill_sessions.status NOT IN ('Deleted')"]
  accepts_nested_attributes_for :balance_bill_sessions

  has_many :balance_bill_payments, :dependent => :destroy, :conditions => ["balance_bill_payments.status NOT IN ('Deleted')"]
  accepts_nested_attributes_for :balance_bill_payments

  # relationship for invoicing
  has_many :invoice_detail, :as => :idetailable, :dependent => :destroy
  has_many :dataerrors, :as => :dataerrorable, :dependent => :destroy

  # paper trail versions
  has_paper_trail :class_name => 'BalanceBillVersion'

  #
  # callbacks
  #
  before_validation :format_date,               :unless => :skip_callbacks
  before_save       :update_balance_bill,       :unless => :skip_callbacks    # updates the amounts, and balance bill session records
  after_save        :validate_balance_bill,     :unless => :skip_callbacks
  before_destroy    :check_state_and_reset


  #
  # assignments
  #

  # allows the skipping of callbacks to save on database loads
  # use InsuranceBilling.skip_callbacks = true to set, or in update_attributes(..., :skip_callbacks => true)
  cattr_accessor :skip_callbacks

  attr_accessible :closed_date, :invoice_date, :patient_id, :comment, :provider_id,
                  :payment_amount, :total_amount, :balance_owed, :invoiced_id,
                  :late_amount, :adjustment_description, :adjustment_amount, :balance_bill_sessions_attributes,
                  :created_user, :updated_user,
                  :unformatted_closed_date,  # used for datepicker
                  :unformatted_invoice_date,  # used for datepicker
                  :skip_callbacks
  attr_protected :status, :balance_status
  attr_accessor :unformatted_invoice_date, :unformatted_closed_date

  #
  # scopes
  #

  scope :billable, :conditions => ["balance_bills.invoice_id IS NULL"]

  #
  # validations
  #
  validates :patient_id, :presence => true
  validates :provider_id, :presence => true
  validates :created_user, :presence => true

  #
  # instance methods
  #

  #
  # reformat the date of service from m/d/y to y/m/d for sotring in db
  #
  def format_date
    begin
      if !self.unformatted_invoice_date.blank?
        self.invoice_date = Date.strptime(self.unformatted_invoice_date, "%m/%d/%Y").to_time(:utc)
      end
      if !self.unformatted_closed_date.blank?
        self.closed_date = Date.strptime(self.unformatted_closed_date, "%m/%d/%Y").to_time(:utc)
      end
    rescue
      errors.add :base, "Invalid Date(s)"
    end
  end


  #
  # called directly from the ajax routine when creating a new balance bill
  #
  def build_balance_bill
    self.invoice_date = DateTime.now.strftime("%d/%m/%Y")
    self.payment_amount = 0.00
    self.late_amount = 0.00
    self.adjustment_amount = 0.00

    # build the balance bill session record relationships
    @bal_bill_sessions = BalanceBillSession.patient_pending(self.patient_id)
    self.balance_bill_sessions << @bal_bill_sessions

    @total = 0.0
    #loop through sessions and sum up totals
    self.balance_bill_sessions.each do |session|
      @total += session.total_amount
    end
    self.total_amount = @total
    self.balance_owed = @total
  end


  #
  # updates the total amounts, the balance bill session records and history
  #
  def update_balance_bill
    # sum up the payments
    @payment = 0
    self.balance_bill_payments.each do |payment|
      @payment += payment.payment_amount
    end
    self.payment_amount = @payment

    # sum up the totals for all the sessions
    @total = 0.0
    self.balance_bill_sessions.each do |bb_session|
      @total += bb_session.total_amount if bb_session.disposition == BalanceBillSession::INCLUDE
      if bb_session.disposition == BalanceBillSession::SKIP
        # remove the record from the association
        self.balance_bill_sessions.delete(bb_session)
        # reset the disposition to include
        bb_session.update_column(:disposition, BalanceBillSession::INCLUDE)
      end
    end
    # set the adjustment amt and late amt to 0 if they are nil
    self.adjustment_amount ||= 0.0
    self.late_amount ||= 0.0
    # update the total amount due
    self.total_amount = @total + self.adjustment_amount + self.late_amount
    #calculate the balance due
    self.waived_amount ||= 0
    self.balance_owed = self.total_amount - self.payment_amount - self.waived_amount

    return true
  end


  #
  # check to make sure all related records for this balance bill are completed correctly
  #
  def validate_balance_bill
      # check the system info record
      @system_info = SystemInfo.first
      @count = @system_info == nil ? 1 : @system_info.dataerrors.count
      #check self for any errors
      @count += self.dataerrors.count
      #check the patient
      @count += self.patient.dataerrors.count

      # loop through and check the session for any errors
      # only check the included sessions
      self.balance_bill_sessions.each do |bb_session|
        if bb_session.disposition == BalanceBillSession::INCLUDE
          @count += bb_session.dataerrors.count
          @count += bb_session.insurance_session.dataerrors.count
          @count += bb_session.provider.dataerrors.count
          @count += bb_session.group.dataerrors.count if !bb_session.group.blank?
        end
      end

      self.transaction do
        # update the errors, error_count and status fields without validations
        self.update_column(:dataerror, @count > 0)
        self.update_column(:dataerror_count, @count)
      end  # end transaction
  end   # end validate_balance_bill

  #
  # when deleting a balance bill, first check the balance bill rules to see if it can be deleted
  # if it can then reset the balance bill session records
  #
  def check_state_and_reset
    #balance_status must be  bill
    if self.balance_bill_deleteable?
      logger.info "balance bill deletable"
      self.balance_bill_sessions.each do |bb_session|
        bb_session.update_attributes(:balance_bill_id => nil, :disposition => BalanceBillSession::INCLUDE)
      end
    else
      logger.info "balance bill not deleteable"
      return false
    end
    return true
  end


  # revert the balance bill to the previous state
  # note: to peroperly revert, when creating / editing a payment, must do the chnages using the
  # balance bill record, so papertrail keeps both balance bill and payments in sync with the number of recorded changes
  def revert
    version = BalanceBillVersion.find(self.versions.last.id) if self.versions.last
    # if there are versions then revert to the previous one.
    if !version.blank? && version.reify
      self.transaction do
        # if the current status is :partial_payment or :paid_in_full then delete the last payment
        self.balance_bill_payments.last.revert if self.payment_made_current? && self.balance_bill_payments.last
        version.reify.save
      end
    else
      return false
    end
    return true
  end


end
