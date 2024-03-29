class BalanceBillSession < ActiveRecord::Base
  #
  # includes
  #
  include CommonStatus

  #
  # model associations
  #
  belongs_to :balance_bill
  belongs_to :insurance_session
  belongs_to :patient
  belongs_to :provider
  belongs_to :group

  has_many :balance_bill_details, :dependent => :destroy, :conditions => ["balance_bill_details.status NOT IN ('Deleted')"]
  accepts_nested_attributes_for :balance_bill_details, :allow_destroy => true

  has_many :dataerrors, :as => :dataerrorable, :dependent => :destroy

  # paper trail versions
  has_paper_trail :class_name => 'BalanceBillSessionVersion'

  #
  # constants
  #

  # disposition of the balance bill session records
  INCLUDE = 100  # default - include the session on the balance bill
  WAIVE   = 200  # do not include this record on the balance bill
  SKIP    = 300  # skip this balance bill session record on the balance bill, but allow it to appear on a future balance bills


  #
  # callbacks
  #

  after_initialize  :build_balance_bill_session
  before_validation :update_balance_bill_details, :unless => :skip_callbacks
  after_save        :update_session_finance,      :unless => :skip_callbacks   # saves the related session record to force finance updates
  after_save        :validate_data,               :unless => :skip_callbacks
  before_destroy    :reset_balance_bill_id,       :unless => :skip_callbacks

  #
  # assignments
  #

  # allows the skipping of callbacks to save on database loads
  # use InsuranceBilling.skip_callbacks = true to set, or in update_attributes(..., :skip_callbacks => true)
  cattr_accessor :skip_callbacks
  attr_accessible :dos, :patient_id, :group_id, :provider_id, :total_amount, :disposition,
                  :created_user, :updated_user, :balance_bill_details_attributes, # for accepting balance_bill_details records
                  :skip_callbacks
  attr_protected :status

  #
  # scopes
  #

  # select all the balance bill sessions not associated to a balance bill and unique patients.
  scope :pending, :conditions => ["balance_bill_sessions.balance_bill_id IS ? and balance_bill_sessions.status NOT IN ('Deleted')", nil],
                  :include => [:patient],
                  :order => ["patients.last_name DESC"]

  scope :patient_pending, lambda { |patient_id| {
                  :conditions => ["balance_bill_sessions.balance_bill_id IS ? and balance_bill_sessions.patient_id = ? and balance_bill_sessions.status NOT IN ('Deleted')", nil, patient_id],
                  :include => [:provider, :group],
                  :order => :dos
                  }}

  #
  # validations
  #

  validates :disposition, :presence => true
  validates :patient_id, :presence => true
  validates :provider_id, :presence => true
  validates :created_user, :presence => true

  #
  # instance methods
  #

  #
  # build the balance bill session record and the first detail record
  #
  def build_balance_bill_session
    # if patient_id is not set, then new record. need to build out the default fields
    if !self.patient_id?
      self.patient_id = self.insurance_session.patient_id
      self.group_id =  self.insurance_session.group_id
      self.provider_id =  self.insurance_session.provider_id
      self.dos = self.insurance_session.dos
      self.disposition = INCLUDE
      # the balance_due is set from the session's balance_owed.  if null balance_owed, then set to 0.
      # on every balance bill update and/or ins billing update, the session charges are recalculated, so the balance_owed is accurate
      self.total_amount = self.insurance_session.balance_owed.blank? ? 0 : self.insurance_session.balance_owed

      # create a detail record for the deductible; so that when client invoicing we can pull it out.
      if !self.insurance_session.deductible_amount.blank? && self.insurance_session.deductible_amount > 0
        self.balance_bill_details.new(:created_user => self.created_user, :amount => self.insurance_session.deductible_amount, :quantity => 1,
                                    :description => "Deductible for date of service: #{self.dos.strftime("%m/%d/%Y")}", :detail_status => BalanceBillDetail::DEDUCTIBLE)
        self.total_amount -= self.insurance_session.deductible_amount
      end
      #create the detail record for the balance bill for all charges minus the deductible.
      self.balance_bill_details.new(:created_user => self.created_user, :amount => self.total_amount, :quantity => 1,
                                    :description => "Balance owed for date of service: #{self.dos.strftime("%m/%d/%Y")}", :detail_status => BalanceBillDetail::BALANCE)
    end
  end



  # before validating for save or update
  # set the created and updated users in each detail record
  # sum up the total amount of the details to get the full total amount for the session's balance bill
  def update_balance_bill_details
    # reset total amount to 0
    self.total_amount = 0

    #loop through all the detail records,
    self.balance_bill_details.each do |detail|
      #set the created and updated users
      detail.created_user = self.created_user
      detail.updated_user = self.updated_user
      #sum up all the detail amounts to get new total amount
      self.total_amount += detail.amount.to_f if detail.amount? && !detail.status?(:deleted)
    end
  end

    #
    # saves the related session record to force a re-calc of the finances
    #
    def update_session_finance
      logger.info "Updated Session Finance: Balance Bill ID: #{self.id}, Session ID: #{self.insurance_session_id}, Patient ID: #{self.patient_id}, Provider ID: #{self.provider_id}"
      # set the insurance session status
      @session = self.insurance_session
      #secondary status will be primary / secondary/ tertiary or other
      @session.status = SessionFlow::BALANCE
      @session.updated_user = self.updated_user.blank? ? self.created_user : self.updated_user
      return self.insurance_session.save  # recalculates the charges with the callbacks
    end

  #
  # validate this database reocrd to confirm all fields are entered corrcetly
  #
  def validate_data
    begin
      #first remove any old errors from the table
      self.dataerrors.clear

      @s = []
      # check the necessary fields in the table
      # use the build method so the polymorphic reference is generated cleanly
      # the following to check should never be possible.  claims are always associated to a patient and session
      @s.push self.dataerrors.build(:message => "No Patient associated to a session included in the balance bill; Delete this invoice and create a new one", :created_user => self.created_user) if self.patient_id.blank?
      @s.push self.dataerrors.build(:message => "No Session associated to a session included in the balance bill; Delete this invocie and create a new one", :created_user => self.created_user) if self.insurance_session_id.blank?
      # check for the relationships to other tables
      @s.push self.dataerrors.build(:message => "No provider associated to a claim included in the balance bill", :created_user => self.created_user) if self.provider_id.blank?

      # check the fields within insurance billing
      @s.push self.dataerrors.build(:message => "A Session has a $0.00 balance amount. Edit the balance amount or waive the session on the balance bill.", :created_user => self.created_user) if self.total_amount.blank? || self.total_amount == 0

      #if there are errors, save them to the dataerrors table and return false
      Dataerror.store(@s) if @s.count > 0
    rescue
      errors.add :base, "failed to validate balance billing record"
      return false
    end
    return true   #everything is good, return true
  end

  #
  # reset the balance_id to nil
  # called primarily when the balance bill is deleted.
  def reset_balance_bill_id
    self.balance_bill_id = nil
  end

  def disposition_text
    case self.disposition
    when INCLUDE
      return "Include"
    when WAIVE
      return "Waive"
    when SKIP
      return "Skip"
    end
  end

end
