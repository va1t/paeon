class InvoiceDetail < ActiveRecord::Base
  #
  # include statements
  #
  include CommonStatus

  #
  # model associations
  #
  belongs_to :invoice
  belongs_to :idetailable, :polymorphic => true

  # paper trail versions
  has_paper_trail :class_name => 'InvoiceDetailVersion'


  #
  # constants
  #
  # these are the types of invoice detail records we can have
  FEE       = 100     # detail is a fee based calculation
  CLAIM     = 200     # detail is a claim
  BALANCE   = 300     # balance bill record
  COB       = 400     # coordination of benefits fee
  DENIED    = 500     # claim denied fee
  SETUP     = 600     # new client setup fee
  DISCOVERY = 700     # discovery fee
  ADMIN     = 800     # admin fee
  ADHOC     = 900     # the detailed record is an ad hoc record added to the invoice

  # status of the invoice detail
  INCLUDE = 100  # default - include the charge onthe invoice
  WAIVE   = 200  # do not include this record on an invoice.
  SKIP    = 300  # skip this invoice detail record on the invoice, but allow it to appear on a future invoice

  #
  # callbacks
  #
  before_validation :format_date

  #
  # model assignments
  #

  # allows the skipping of callbacks to save on database loads
  # use InsuranceBilling.skip_callbacks = true to set, or in update_attributes(..., :skip_callbacks => true)
  cattr_accessor :skip_callbacks

  attr_accessible :idetailable_type, :idetailable_id, :record_type, :dos, :provider_name, :group_name, :disposition,
                  :ins_paid_amount, :ins_billed_amount, :charge_amount, :patient_name, :claim_number, :insurance_name, :description,
                  :admin_fee, :discover_fee, :created_user, :updated_user,
                  :unformatted_dos

  attr_accessor   :unformatted_dos

  attr_protected  :status

  #
  # validations
  #
  validates :patient_name,   :length => {:maximum => 80  }, :allow_nil => true, :allow_blank => true
  validates :claim_number,   :length => {:maximum => 50  }, :allow_nil => true, :allow_blank => true
  validates :insurance_name, :length => {:maximum => 100 }, :allow_nil => true, :allow_blank => true

  validates :ins_paid_amount,   :numericality => true, :allow_nil => true, :allow_blank => true
  validates :ins_billed_amount, :numericality => true, :allow_nil => true, :allow_blank => true
  validates :charge_amount,     :numericality => true, :allow_nil => true, :allow_blank => true
  validates :admin_fee,     :inclusion => {:in => [true, false]}
  validates :discovery_fee, :inclusion => {:in => [true, false]}

  validates :created_user, :presence => true


  #
  # instance methods
  #

  # reformat the dates from m/d/y to y/m/d for storing in db
  def format_date
    begin
      self.dos = Date.strptime(self.unformatted_dos, "%m/%d/%Y").to_time(:utc) if !self.unformatted_dos.blank?
    rescue
      errors.add :base, "Invalid Date(s)"
      return false
    end
  end

  def record_type_to_text
    case self.record_type
    when FEE
      str = "Fee Based Charge"
    when CLAIM
      str = "Claim"
    when BALANCE
      str = "Balance Bill"
    when COB
      str = "Coord Benefits"
    when DENIED
      str = "Claim Denied"
    when SETUP
      str = "Patient Setup"
    when DISCOVERY
      str = "Discovery"
    when ADMIN
      str = "Administrative"
    else
      str ="Ad Hoc"
    end
    return str
  end


  def disposition_to_text
    case self.disposition
    when INCLUDE
      str = "Included"
    when WAIVE
      str = "Waived"
    else SKIP
      str = "Skipped"
    end
    return str
  end

  #
  # class methods
  #

  def self.disposition_to_text(disposition)
    case disposition
    when INCLUDE
      str = "Included"
    when WAIVE
      str = "Waived"
    else SKIP
      str = "Skipped"
    end
    return str
  end

end
