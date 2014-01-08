class BalanceBillPayment < ActiveRecord::Base
  #
  # includes
  #
  include CommonStatus

  #
  # model associations
  #

  belongs_to :balance_bill

  # paper trail versions
  has_paper_trail :class_name => 'BalanceBillPaymentVersion'

  #
  # constants
  #

  # for the payment method dropdown box in manual eobs
  PAYMENT_METHOD = ["CHK", "Cash", "Credit", "ACH"]


  #
  # callbacks
  #
  after_initialize  :build_balance_bill_payment, :unless => :skip_callbacks
  before_validation :format_date,                :unless => :skip_callbacks


  #
  # assignments
  #

  # allows the skipping of callbacks to save on database loads
  # this is used pricipall for testing, to isolate the callbacks
  # use InsuranceSession.skip_callbacks = true to set, or in update_attributes(..., :skip_callbacks => true)
  cattr_accessor  :skip_callbacks
  attr_accessible :balance_amount, :payment_amount, :payment_method, :check_number,
                  :created_user, :updated_user,
                  :unformatted_payment_date,
                  :skip_callbacks            # need to make this accessible for tests
  attr_accessor   :unformatted_payment_date

  #
  # scopes
  #

  #
  # validations
  #
  validates :payment_amount, numericality: true
  validates :created_user, :presence => true

  #
  # instance methods
  #

  #
  # reformat the payment date from m/d/y to y/m/d for sotring in db
  #
  def format_date
    begin
      if !self.unformatted_payment_date.blank?
        self.payment_date = Date.strptime(self.unformatted_payment_date, "%m/%d/%Y").to_time(:utc)
      end
    rescue
      errors.add :base, "Invalid Date(s)"
    end
  end


  #
  # this is called after initialization.  If the id field is blank then set the field defaults
  # unless they have already been set
  def build_balance_bill_payment
    if self.id.blank?
      self.payment_date ||= DateTime.now.strftime("%d/%m/%Y")
      self.payment_amount ||= 0.00
    end
  end


  # revert the balance bill payment to the previous state
  def revert
    version = BalanceBillPaymentVersion.find(self.versions.last.id)
    # if there are versions then revert to the previous one.
    if version.reify
      self.transaction do
        version.reify.save
      end
    else
      self.destroy
    end
    return true
  end


end
