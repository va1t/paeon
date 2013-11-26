class Eob < ActiveRecord::Base

  belongs_to :patient
  belongs_to :insurance_billing
  belongs_to :provider
  belongs_to :group
  belongs_to :subscriber
  belongs_to :insurance_company
  belongs_to :invoice

  has_many :eob_details, :dependent => :destroy
  accepts_nested_attributes_for :eob_details, :allow_destroy => true

  has_many :eob_claim_adjustments, :dependent => :destroy
  accepts_nested_attributes_for :eob_claim_adjustments, :allow_destroy => true

  has_many :notes, :as => :noteable, :dependent => :destroy

  # paper trail versions
  has_paper_trail :class_name => 'EobVersion'

  #default scope hides records marked deleted
  default_scope where(:deleted => false)

  #edi eobs can fail to be assigned to an open claim
  scope :assigned,   :include => [:patient, :provider],
                     :joins => [:insurance_billing],
                     :conditions => ["insurance_billings.status = ?", BillingFlow::PAID],
                     :order => "providers.last_name ASC, patients.last_name ASC, eobs.dos ASC"

  # sorting order for the unassignd may be weird because it is using the last name for the provider and patient that is
  # returned from the insurance company.  each insurance company may have a slightly different last name for the provider
  # if they also included the provider certifications along with the last name.
  scope :unassigned, :conditions => ["insurance_billing_id IS NULL"],
                     :order => "provider_last_name ASC, patient_last_name ASC, eobs.dos ASC"

  # allows the skipping of callbacks to save on database loads
  # this is used pricipall for testing, to isolate the callbacks
  # use InsuranceSession.skip_callbacks = true to set, or in update_attributes(..., :skip_callbacks => true)
  cattr_accessor :skip_callbacks

  before_validation :format_date, :unless => :skip_callbacks
  before_save :update_eob_fields, :unless => :skip_callbacks        # update the eob fields from the claim
  before_save :update_table_links, :unless => :skip_callbacks       # update all the *_id fields using the ins_bill rec, if assigned
  after_save :update_other_tables, :unless => :skip_callbacks       # update status fields in ins_bill; balance due fields...

  attr_accessible :insurance_billing_id, :insurance_company_id, :payor_name, :provider_id, :group_id,
                  :claim_number, :eob_date, :dos, :group_number, :payment_amount, :charge_amount, :payor_claim_number,
                  :check_number, :check_date, :check_amount, :check_number_old,
                  :subscriber_id, :subscriber_first_name, :subscriber_last_name, :subscriber_amount,
                  :patient_id, :patient_first_name, :patient_last_name,
                  :ref_class_contract, :ref_authorization_number, :payment_method, :bpr_monetary_amount, :trn_payor_identifier,
                  :created_user, :updated_user, :deleted,

                  :claim_date, :service_start_date, :service_end_date, :subscriber_ins_policy, :claim_status_code, :claim_indicator_code,
                  :payor_contact, :payor_contact_qualifier, :provider_first_name, :provider_last_name, :provider_npi, :payee_name,
                  :payee_npi, :payee_payor_id, :payee_ein, :payee_ssn, :payee_address1, :payee_address2, :payee_city, :payee_state, :payee_zip, :manual,

                  :unformatted_eob_date,     # for use with datepicker
                  :unformatted_dos,          # for use with datepicker
                  :unformatted_check_date,   # for use with datepicker
                  :eob_details_attributes,   # for accepting eob_details records
                  :skip_callbacks            # need to make this accessible for tests

  # Fields not accessible for updating directly from a form.  These folowing fields are filled in programatically
  # claim_date, service_start_date, service_end_date, subscriber_ins_policy, claim_status_code, claim_indicator_code,
  # payor_contact, payor_contact_qualifier,
  # provider_first_name, provider_last_name, provider_npi, payee_name, payee_payor_id, payee_ein, payee_ssn,
  # payee_address1, payee_address2, payee_city, payee_state, payee_zip

  attr_accessor   :unformatted_eob_date, :unformatted_dos, :unformatted_check_date


  # for the payment method dropdown box in manual eobs
  PAYMENT_METHOD = ["CHK", "ACH"]

  validates :dos, :presence => true
  validates :eob_date, :presence => true
  validates :payment_amount, :presence => true
  validates :charge_amount, :presence => true

  # override the destory method to set the deleted boolean to true.
  def destroy
    run_callbacks :destroy do
      #the insurance billing record status need to be revertd back so it appears in the claims outstanding box
      #dont know if it was submitted or printed, so use error as a revert
      self.insurance_billing.revert_to_previous_status if !self.insurance_billing_id.blank?
      self.update_column(:deleted, true)
    end
  end


  # formats the providers name using the last name and first name supplied by the eob
  def eob_provider_name
    str = ""    #initialize in case the fieds are blank
    str += self.provider_last_name.upcase if !self.provider_last_name.blank?
    str += ", "
    str += self.provider_first_name.upcase if !self.provider_first_name.blank?
    return str
  end


  # formats the patients name using the last name and first name supplied by the eob
  def eob_patient_name
    str = ""    #initialize in case the fileds are blank
    str += self.patient_last_name.upcase if !self.patient_last_name.blank?
    str += ", "
    str += self.patient_first_name.upcase if !self.patient_first_name.blank?
    return str
  end


  # reformat the dates from m/d/y to y/m/d for storing in db
  def format_date
    begin
      self.eob_date = Date.strptime(self.unformatted_eob_date, "%m/%d/%Y").to_time(:utc) if !self.unformatted_eob_date.blank?
      self.dos = Date.strptime(self.unformatted_dos, "%m/%d/%Y").to_time(:utc) if !self.unformatted_dos.blank?
      self.check_date = Date.strptime(self.unformatted_check_date, "%m/%d/%Y").to_time(:utc) if !self.unformatted_check_date.blank?
    rescue
      errors.add :base, "Invalid Date(s)"
    end
  end

  #
  # fillin eob fields from the cliam to make sure the eob is complete
  # if a detail record is not attached, auto create it
  def update_eob_fields
    if self.manual && self.eob_details.blank?
      self.eob_details.new(:dos => self.dos, :charge_amount => self.charge_amount, :payment_amount => self.payment_amount, :created_user => self.created_user)
    end
  end

  #
  # update all the internal eob *_id fields using ins_bill
  # if the insurance billing record exists
  def update_table_links
    if !self.insurance_billing_id.blank?
      self.provider_id = self.insurance_billing.provider_id
      self.group_id = self.insurance_billing.group_id
      self.patient_id = self.insurance_billing.patient_id
      self.subscriber_id = self.insurance_billing.subscriber_id
      self.insurance_company_id = self.insurance_billing.insurance_company_id
    end
  end

  # Updates all of the necessary tables
  # Ins Sessions - update of the owed balance, summing all claims and all eobs
  # Ins Billing - Update status
  def update_other_tables
    # unassigned eobs will not have a link to insurance billings.
    # if the status is greater than paid, leave it alone.
    # if the status is paid, we need to still update the session.  a manual second eob may be entered.
    if !self.insurance_billing_id.blank? && self.insurance_billing.status <= BillingFlow::PAID
      # eob has been received, so mark the claim as paid
      # this triggers the updating of the balance owed; also triggers the updating of manage care records if any
      self.insurance_billing.update_attributes(:status => BillingFlow::PAID, :updated_user => (self.updated_user.blank? ? self.created_user : self.updated_user))
      # re-calc all the fields belonging to the session.
      self.insurance_billing.insurance_session.save!
    end
  end


end

