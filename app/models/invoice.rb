class Invoice < ActiveRecord::Base
  include InvoiceCalculation
  
  belongs_to :invoiceable, :polymorphic => true
  has_many   :invoice_details,  :dependent => :destroy, :order => "provider_name ASC, patient_name ASC, dos ASC"
  accepts_nested_attributes_for :invoice_details, :allow_destroy => true
  
  has_many   :invoice_payments, :dependent => :destroy
  accepts_nested_attributes_for :invoice_payments, :allow_destroy => true
  
  #default scope hides records marked deleted
  default_scope where(:deleted => false) 

  scope :not_closed, :conditions => ["invoices.status < ?", InvoiceFlow::CLOSED] 
  
  scope :current, lambda { |x| {:conditions => ["invoices.id = ?", x],
                               :joins => :invoice_details,
                               :order => "invoice_details.provider_name, invoice_details.patient_name, invoice_details.dos"}}
  
  
  after_initialize :build_invoice
  before_validation :format_date
  before_save :calculate_invoice
  after_save :update_associated_records  
  
  attr_accessible :invoiceable_type, :invoiceable_id, :status,
                  :created_date, :sent_date, :second_notice_date, :third_notice_date, :deliquent_notice_date, :closed_date, 
                  :total_invoice_amount, :balance_owed_amount,                  # total of the invoice, and the total oustanding balance 
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
                  :created_user, :updated_user, :deleted,
                  :invoice_details_attributes,
                  :unformatted_created_date,
                  :unformatted_fee_start,
                  :unformatted_fee_end

  attr_accessor   :unformatted_created_date, :unformatted_fee_start, :unformatted_fee_end
  
  validates :invoiceable_type, :presence => {:message => "Provider or Group must be selected."}
  validates :invoiceable_id,   :presence => {:message => "Provider or Group must be selected."}
  
  validates :count_claims,    :numericality => {:only_integer => true}
  validates :count_balances,  :numericality => {:only_integer => true}
  validates :count_cob,       :numericality => {:only_integer => true}
  validates :count_denied,    :numericality => {:only_integer => true}
  validates :count_setup,     :numericality => {:only_integer => true}
  validates :count_admin,     :numericality => {:only_integer => true}
  validates :count_discovery, :numericality => {:only_integer => true}
  
  validates :deleted, :inclusion => {:in => [true, false]}
  validates :created_user, :presence => true


  # override the destory method to set the deleted boolean to true.
  def destroy
    #free the associated records before deleting
    self.invoice_details.each do |d|
      #get the associated record
      if d.record_type > InvoiceDetailType::FEE && d.record_type <= InvoiceDetailType::SETUP
        @object = d.idetailable_type.classify.constantize.find(d.idetailable_id)     
        @object.update_attributes(:invoiced => false, :invoice_id => nil, :skip_callbacks => true)
      end
    end

    run_callbacks :destroy do    
      self.update_column(:deleted, true)
    end
  end    


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
  # update the invoice and invoice_id fields in the associated tables
  # insurance_billings, balance_bills, patients_provider and patients_group tables
  def update_associated_records
    self.invoice_details.each do |d|
      if d.record_type > InvoiceDetailType::FEE && d.record_type <= InvoiceDetailType::SETUP 
        #get the associated record
        @object = d.idetailable_type.classify.constantize.find(d.idetailable_id)
        
        if d.status == InvoiceDetailType::INCLUDE || d.status == InvoiceDetailType::WAIVE
          @object.update_attributes(:invoiced => true, :invoice_id => self.id, :skip_callbacks => true)
        elsif @object.invoice_id == self.id
          # the record is to be skipped.  If the record was invoiced under this invoice
          # then we want to set the invoice flag to false so it is picked up in future invoices
          @object.update_attributes(:invoiced => false, :invoice_id => nil, :skip_callbacks => true)
        end
      end 
    end # end loop
  end
  
  
  # after initialize builds out the full invoice record with detail records
  # calculates the inital charges
  def build_invoice
    # if status is nil then this is a new record and need to build out the invoice
    if !self.status      
      # pulls the fees and methods from the group / provider
      # fills in the invoice record with the provider specific information
      self.status = InvoiceFlow::INITIATE
      self.created_date = DateTime.now.strftime("%d/%m/%Y")  
      self.balance_owed_amount = 0  
  
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
  
      # build the detail records
      build_detail_fee_based if self.invoice_method != PERCENT
      build_detail_claims
      build_detail_balance_bills
      build_detail_setup
      
      # sort the invoice_details by provider, patient, dos
      # use sort_by because this is all in memory  
      self.invoice_details.sort_by!{|x| [x.provider_name, x.patient_name, x.dos] }
      
      # calculate the charges for the invoice
      calculate_invoice
    end
  end

  #
  # if the invocie calculation method is flat fee or dos fee, add the first detail record for the invoice
  # to capture the fee based charge.  The claims and balance bill detail is required for backup.
  # this record maintains the charge amount once calculated.
  # there should only be one fee based recrod per invoice and it should be the first record.
  def build_detail_fee_based
    details = self.invoice_details.new(:created_user => self.created_user, :record_type => InvoiceDetailType::FEE, :provider_name => 'a',
                                       :patient_name => 'a', :dos => Date.today, :status => InvoiceDetailType::INCLUDE)
  end


  def build_detail_claims
    # pull all of the claims; sum up the eob payments made
    @claims = @object.insurance_billings.billable.includes(:patient, :provider, :eobs, :insurance_company)
    total_claim_charge = 0
    total_claim_payment = 0
    
    @claims.each do |c|
      #create the details record 
      total_claim_charge += c.insurance_billed      
      details = self.invoice_details.new(:idetailable_type => "InsuranceBilling", :idetailable_id => c.id, :created_user => self.created_user,
                     :ins_billed_amount => c.insurance_billed, :record_type => InvoiceDetailType::CLAIM, :patient_name => c.patient.patient_name, 
                     :claim_number => c.claim_number, :insurance_name => c.insurance_company.name, :dos => c.dos, 
                     :provider_name => c.provider.provider_name, :status => InvoiceDetailType::INCLUDE)
      ins_paid = 0
      c.eobs.each do |e|
        # add up all the eob payments made
        ins_paid += e.payment_amount if e.payment_amount > 0
      end
      total_claim_payment += ins_paid
      details.ins_paid_amount = ins_paid
      # if the insurance paid 0 then it is either a COB or Denied claim
      if ins_paid == 0
        # determine if the cob and denied claim fees apply
        details.record_type = InvoiceDetailType::DENIED
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
    @balance = @object.balance_bills.billable.includes(:patient, :provider)      
    total_balance_charge = 0
    total_balance_payment = 0 
    @balance.each do |b|
      details = self.invoice_details.new(:idetailable_type => "BalanceBill", :idetailable_id => b.id, :created_user => self.created_user,
                     :ins_billed_amount => b.total_invoice_amount, :ins_paid_amount => b.payment_received_amount, :patient_name => b.patient.patient_name,  
                     :claim_number => b.invoice_date.strftime("%m/%d/%Y"), :record_type => InvoiceDetailType::BALANCE, 
                     :provider_name => c.provider.provider_name, :status => InvoiceDetailType::INCLUDE)
      total_balance_charge += b.total_invoice_amount
      total_balance_payment += b.payment_received_amount
    end
    self.count_balances = @balance.count
  end
  
  
  def build_detail_setup
    # add the client setup records
    if self.invoiceable_type == "Group"
      @assoc_patients = @object.patients_groups.where(:invoiced => false).includes(:patient, :provider)
      @association = "PatientsGroup"
    else
      @assoc_patients = @object.patients_providers.where(:invoiced => false).includes(:patient, :provider)
      @association = "PatientsProvider"  
    end
    
    @assoc_patients.each do |p|
      # create the detailed line item for the patient.  use the dos field to capture the date the patient was setup
      details = self.invoice_details.new(:idetailable_type => @association, :idetailable_id => p.id, :created_user => self.created_user,
                     :patient_name => p.patient.patient_name, :provider_name => p.provider.provider_name, :record_type => InvoiceDetailType::SETUP,
                     :status => InvoiceDetailType::INCLUDE, :dos => p.created_at)
    end
    self.count_setup = @assoc_patients.count
  end

end
