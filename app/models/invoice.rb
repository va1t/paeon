#
# All workflow and state machine related methods are stored in libs/workflow/invoice_status.rb
# All invoice calculations are stored in libs/invoice_calculation.rb
# The methods to build an invoice collect the records.  The actual charge calculation is stored in invoice calculations
#
class Invoice < ActiveRecord::Base
  #
  # includes
  #
  include CommonStatus
  include InvoiceStatus
  include InvoiceCalculation

  #
  # model associations
  #
  belongs_to :invoiceable, :polymorphic => true

  has_many   :invoice_details,  :dependent => :destroy,
             :order => "provider_name ASC, patient_name ASC, dos ASC"
            #:conditions => ["invoice_details.status NOT IN ('Deleted')"],
  accepts_nested_attributes_for :invoice_details, :allow_destroy => true

  has_many   :invoice_payments, :dependent => :destroy,
             :conditions => ["invoice_payments.status NOT IN ('Deleted')"]
  accepts_nested_attributes_for :invoice_payments, :allow_destroy => true

  # these models have links to the invoice. when deleting the invoice, want to make sure we nullify the pointer so
  # the records can be included in future invoice
  has_many :balance_bills,      :dependent => :nullify
  has_many :eobs,               :dependent => :nullify
  has_many :patients_providers, :dependent => :nullify
  has_many :patients_groups,    :dependent => :nullify

  # store the errors on the invoice record
  has_many :dataerrors, :as => :dataerrorable, :dependent => :destroy

  # paper trail versions
  has_paper_trail :class_name => 'InvoiceVersion'


  #
  # contants
  #

  # payment terms for invoices
  # defining the majority fo the terms so that the numbering sequence is established
  NET10 = 10
  NET15 = 15
  NET20 = 20
  NET30 = 30
  NET45 = 45
  NET50 = 50
  NET60 = 60
  NET75 = 75
  NET90 = 90

  # constant array is utilized in populating the dropdown selects for payment terms
  PAYMENT_TERMS = [["Net 20", NET20], ["Net 30", NET30], ["Net 45", NET45], ["Net 60", NET60]]

  #
  # callbacks
  #

  after_initialize  :build_invoice,             :unless => :skip_callbacks
  before_validation :format_date,               :unless => :skip_callbacks
  after_save        :update_associated_records, :unless => :skip_callbacks

  #
  # assignments
  #

  # allows the skipping of callbacks to save on database loads
  # use InsuranceBilling.skip_callbacks = true to set, or in update_attributes(..., :skip_callbacks => true)
  cattr_accessor :skip_callbacks

  attr_accessible :invoiceable_type, :invoiceable_id, :created_date, :sent_date, :second_notice_date, :third_notice_date, :deliquent_notice_date, :closed_date,
                  :total_invoice_amount, :balance_owed_amount,                  # total of the invoice, and the total oustanding balance
                  :waived_date, :waived_amount,
                  :total_claim_charge_amount, :total_claim_payment_amount,      # total charge and payment amounts for all claims included in this invoice
                  :total_balance_charge_amount, :total_balance_payment_amount,  # total charge and payment amounts for all balance bills included in this invoice
                  :invoice_method, :fee_start, :fee_end, # store the method of calculation with the invoice, this may change with time
                  # keep track of the total counts of each type of charge int he line items
                  :count_claims, :count_balances, :count_cob, :count_denied,
                  :count_setup, :count_admin, :count_discovery, :count_flat, :count_dos,
                  # store the fees with the invocie for future verification and calculations; fees will change with time
                  :flat_fee, :dos_fee, :claim_percentage, :balance_percentage, :cob_fee, :denied_fee,
                  :setup_fee, :admin_fee, :discovery_fee, :subtotal_claims, :subtotal_balance, :subtotal_setup,
                  :subtotal_cob, :subtotal_denied, :subtotal_admin, :subtotal_discovery, :payment_terms,
                  :created_user, :updated_user, :invoice_details_attributes,
                  :unformatted_created_date, :unformatted_fee_start, :unformatted_fee_end

  attr_accessor   :unformatted_created_date, :unformatted_fee_start, :unformatted_fee_end

  attr_protected  :status

  #
  # scopes
  #
  scope :not_closed, :conditions => ["invoices.invoice_status NOT IN (?) and invoices.status NOT IN (?)", :closed, :deleted]

  scope :current, lambda { |x| {:conditions => ["invoices.id = ?", x],
                               :joins => :invoice_details,
                               :order => "invoice_details.provider_name, invoice_details.patient_name, invoice_details.dos"}}


  #
  # validations
  #
  validates :invoiceable_type, :presence => {:message => "Provider or Group must be selected."}
  validates :invoiceable_id,   :presence => {:message => "Provider or Group must be selected."}

  validates :count_claims,    :numericality => {:only_integer => true}
  validates :count_balances,  :numericality => {:only_integer => true}
  validates :count_cob,       :numericality => {:only_integer => true}
  validates :count_denied,    :numericality => {:only_integer => true}
  validates :count_setup,     :numericality => {:only_integer => true}
  validates :count_admin,     :numericality => {:only_integer => true}
  validates :count_discovery, :numericality => {:only_integer => true}
  validates :created_user, :presence => true


  #
  # instance methods
  #

  # reformat the dates from m/d/y to y/m/d for storing in db
  def format_date
    begin
      self.created_date = Date.strptime(self.unformatted_created_date, "%m/%d/%Y").to_time(:utc) if !self.unformatted_created_date.blank?
      self.fee_start    = Date.strptime(self.unformatted_fee_start,    "%m/%d/%Y").to_time(:utc) if !self.unformatted_fee_start.blank?
      self.fee_end      = Date.strptime(self.unformatted_fee_end,      "%m/%d/%Y").to_time(:utc) if !self.unformatted_fee_end.blank?
    rescue
      errors.add :base, "Invalid Date(s)"
      return false
    end
  end

  #
  # inspects the type of record; returns true if related to a provider
  #
  def provider?
    self.invoiceable_type == "Provider"
  end

  #
  # inspects the type of record; returns true if related to a group
  #
  def group?
    self.invoiceable_type == "Group"
  end

  def term
    case self.payment_terms
      when NET10
        str = "Net 10"
      when NET15
        str = "Net 15"
      when NET20
        str = "Net 20"
      when NET30
        str = "Net 30"
      when NET45
        str = "Net 45"
      when NET50
        str = "Net 50"
      when NET60
        str = "Net 60"
      when NET75
        str = "Net 75"
      when NET90
        str = "Net 90"
      else
        str = "N/A"
    end
    return str
  end

  #
  # update the invoice and invoice_id fields in the associated tables
  # insurance_billings, balance_bills, patients_provider and patients_group tables
  def update_associated_records
    self.invoice_details.each do |d|
      if d.record_type > InvoiceDetail::FEE && d.record_type <= InvoiceDetail::SETUP
        #get the associated record
        @obj = d.idetailable_type.classify.constantize.find(d.idetailable_id)
        if d.disposition == InvoiceDetail::INCLUDE || d.disposition == InvoiceDetail::WAIVE
          @obj.update_attributes(:invoice_id => self.id, :skip_callbacks => true)
        elsif @obj.invoice_id == self.id
          # the record is to be skipped.  If the record was invoiced under this invoice
          # then we want to set the invoice flag to false so it is picked up in future invoices
          @obj.update_attributes(:invoiced => false, :invoice_id => nil, :skip_callbacks => true)
        end
      end
    end # end loop
  end


  # after initialize builds out the full invoice record with detail records
  # calculates the inital charges
  def build_invoice
    # if status is nil then this is a new record and need to build out the invoice
    if self.id.blank?
      # pulls the fees and methods from the group / provider
      # fills in the invoice record with the provider specific information
      self.created_date ||= DateTime.now.strftime("%d/%m/%Y")
      self.balance_owed_amount ||= 0

      #get the group or provider associated to the new record
      @object = self.invoiceable_type.classify.constantize.find(self.invoiceable_id)
      self.invoice_method = @object.invoice_method
      self.payment_terms = @object.payment_terms
      self.flat_fee = @object.flat_fee
      self.dos_fee = @object.dos_fee
      self.claim_percentage = @object.claim_percentage
      self.balance_percentage = @object.balance_percentage
      self.cob_fee = @object.cob_fee
      self.denied_fee = @object.denied_fee
      self.setup_fee = @object.setup_fee
      self.admin_fee = @object.admin_fee
      self.discovery_fee = @object.discovery_fee

      # build the detail records and calculate the invoice if the detail records dont exist
      # when create is called, the detail records exist and calculate invoice will be called with the before save callback
      if self.invoice_details.blank?
        build_detail_fee_based if self.invoice_method != PERCENT
        build_detail_claims
        build_detail_balance_bills
        build_detail_setup

        # calculate the charges for the invoice
        calculate_invoice
      end
    end
  end

  #
  # if the invoice calculation method is flat fee or dos fee, add the first detail record for the invoice
  # to capture the fee based charge.  The claims and balance bill detail is required for backup.
  # this record maintains the charge amount once calculated.
  # there should only be one fee based recrod per invoice and it should be the first record.
  def build_detail_fee_based
    details = self.invoice_details.new(:created_user => self.created_user, :record_type => InvoiceDetail::FEE, :provider_name => 'a',
                                       :patient_name => 'a', :dos => Date.today, :disposition => InvoiceDetail::INCLUDE)
  end


  def build_detail_claims
    # pull all of the claims; sum up the eob payments made
    @eobs = @object.eobs.billable.includes(:patient, :provider, :insurance_billing, :insurance_company).order('providers.last_name, patients.last_name, eobs.dos')
    total_claim_charge = 0
    total_claim_payment = 0

    @eobs.each do |e|
      #create the details record
      total_claim_charge += e.insurance_billing.insurance_billed
      total_claim_payment += e.payment_amount
      details = self.invoice_details.new(:idetailable_type => "Eob", :idetailable_id => e.id, :created_user => self.created_user,
                     :ins_billed_amount => e.insurance_billing.insurance_billed, :record_type => InvoiceDetail::CLAIM, :patient_name => e.patient.patient_name,
                     :claim_number => e.claim_number, :insurance_name => e.insurance_company.name, :dos => e.dos, :ins_paid_amount => e.payment_amount,
                     :provider_name => e.provider.provider_name, :disposition => InvoiceDetail::INCLUDE)

      # if the insurance paid 0 then it is either a COB or Denied claim
      if e.payment_amount == 0
        # determine if the cob and denied claim fees apply
        details.record_type = InvoiceDetail::DENIED
        description = ""
        # loop through the eob details
        e.eob_details.each do |ed|
          # loop through the service adjustments
          ed.eob_service_adjustments.each do |sa|
            carc = CodesCarc.find_by_code(sa.carc1)
            # build the denied reason string
            description += EobCodes::adjustment_group_code(sa.claim_adjustment_group_code) + " - " + (carc.description if !carc.blank?) + "; "
          end
        end
        details.description = description
        self.count_denied += 1
      else
        self.count_claims += 1
      end
    end
    self.total_claim_charge_amount = total_claim_charge
    self.total_claim_payment_amount = total_claim_payment
  end


  def build_detail_balance_bills
    # pull all of the balance bills
    @balance = @object.balance_bills.billable.includes(:patient, :provider).order('providers.last_name, patients.last_name')
    total_balance_charge = 0
    total_balance_payment = 0
    @balance.each do |b|
      details = self.invoice_details.new(:idetailable_type => "BalanceBill", :idetailable_id => b.id, :created_user => self.created_user,
                     :ins_billed_amount => b.total_amount, :ins_paid_amount => b.payment_amount, :patient_name => b.patient.patient_name,
                     :claim_number => b.invoice_date.strftime("%m/%d/%Y"), :record_type => InvoiceDetail::BALANCE, :dos => b.invoice_date,
                     :provider_name => b.provider.provider_name, :disposition => InvoiceDetail::INCLUDE)
      total_balance_charge += b.total_amount
      total_balance_payment += b.payment_amount
    end
    self.count_balances = @balance.count
  end


  def build_detail_setup
    # add the client setup records
    if self.invoiceable_type == "Group"
      assoc_patients = @object.patients_groups.billable.includes(:patient).order('patients.last_name')
      association = "PatientsGroup"
    else
      assoc_patients = @object.patients_providers.billable.includes(:patient).order('patients.last_name')
      association = "PatientsProvider"
    end

    assoc_patients.each do |p|
      if self.invoiceable_type == "Group"
        group_name = p.group.group_name
        provider_name = ""
      else
        group_name = ""
        provider_name = p.provider.provider_name
      end
      # create the detailed line item for the patient.  use the dos field to capture the date the patient was setup
      details = self.invoice_details.new(:idetailable_type => association, :idetailable_id => p.id, :created_user => self.created_user,
                     :patient_name => p.patient.patient_name, :provider_name => provider_name, :group_name => group_name, :record_type => InvoiceDetail::SETUP,
                     :disposition => InvoiceDetail::INCLUDE, :dos => p.created_at)
    end
    self.count_setup = assoc_patients.count
  end


  # revert the balance bill to the previous state
  # note: to peroperly revert, when creating / editing a payment, must do the chnages using the
  # balance bill record, so papertrail keeps both balance bill and payments in sync with the number of recorded changes
  def revert
    version = InvoiceVersion.find(self.versions.last.id) if self.versions.last
    # if there are versions then revert to the previous one.
    if !version.blank? && version.reify
      self.transaction do
        # if the current status is :partial_payment or :paid_in_full then delete the last payment
        self.invoice_payments.last.revert if self.payment_made_current? && self.invoice_payments.last
        version.reify.save
      end
    else
      return false
    end
    return true
  end


  #
  # class methods
  #

  def self.term(payment_terms)
    case payment_terms
      when NET10
        str = "Net 10"
      when NET15
        str = "Net 15"
      when NET20
        str = "Net 20"
      when NET30
        str = "Net 30"
      when NET45
        str = "Net 45"
      when NET50
        str = "Net 50"
      when NET60
        str = "Net 60"
      when NET75
        str = "Net 75"
      when NET90
        str = "Net 90"
      else
        str = "N/A"
    end
    return str
  end

end
