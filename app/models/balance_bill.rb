class BalanceBill < ActiveRecord::Base
  belongs_to :patient
  belongs_to :invoice

  has_many :balance_bill_sessions
  accepts_nested_attributes_for :balance_bill_sessions
  
  has_many :balance_bill_payments, :dependent => :destroy
  accepts_nested_attributes_for :balance_bill_payments
  
  has_many :balance_bill_histories, :dependent => :destroy
  accepts_nested_attributes_for :balance_bill_histories, :allow_destroy => true
  
  # relationship for invoicing
  has_many :invoice_detail, :as => :idetailable, :dependent => :destroy
  has_many :dataerrors, :as => :dataerrorable, :dependent => :destroy
  
  
  #default scope hides records marked deleted
  default_scope where(:deleted => false) 

  #scopes provide consistent access to balance bills with a set status
  scope :initial, :conditions => ["balance_bills.status = ?", BalanceBillFlow::INITIATE]  # initialized
      
  # pending submission
  scope :pending, :conditions => ["balance_bills.status <= ? or balance_bills.status = ?", BalanceBillFlow::READY, BalanceBillFlow::ERRORS],
                  :include => :patient
    
  scope :invoiced, :conditions => ["balance_bills.status >= ? and balance_bills.status < ?", BalanceBillFlow::INVOICED, BalanceBillFlow::CLOSED],
                   :include => :patient

  scope :aged_invoice, lambda { |date| { :conditions => ["balance_bills.status = ? and balance_bills.status < ? and invoice_date < ?", BalanceBillFlow::INVOICED, BalanceBillFlow::CLOSED, date],
                   :include => :patient }}

  scope :errors,    :conditions => ["balance_bills.status = ?", BalanceBillFlow::ERRORS]     # balance bill sent and rejected or more info needed    
  scope :balance,   :conditions => ["balance_bills.status = ?", BalanceBillFlow::BALANCE]    # balance bill has been paid, but there is an outstanding balance
  scope :paid,      :conditions => ["balance_bills.status = ?", BalanceBillFlow::PAID]       # patient invoice paid    
  scope :completed, :conditions => ["balance_bills.status = ?", BalanceBillFlow::CLOSED]     # balance bill is paid & done

  # used for pulling out balanc bills that should be invoiced to the client
  scope :billable,  :conditions => ["balance_bills.status >= ? and balance_bills.status <= ? and balance_bills.invoiced = ?", BalanceBillFlow::PAID, BalanceBillFlow::CLOSED, false]


  after_initialize  :build_balance_bill
  before_validation :format_date, :unless => :skip_callbacks   
  before_save :update_balance_bill, :unless => :skip_callbacks   # updates the amounts, and balance bill session records 
  after_save  :create_history_record, :if => :status_changed?    # create the history record
  after_save  :validate_data, :if => :editable_state?, :unless => :skip_callbacks  # validates the balance bill for readiness 
  after_save  :validate_balance_bill, :if => :editable_state?, :unless => :skip_callbacks
  before_destroy :reset_balance_bill_sessions, :if => :deleteable?


  # allows the skipping of callbacks to save on database loads  
  # use InsuranceBilling.skip_callbacks = true to set, or in update_attributes(..., :skip_callbacks => true)
  cattr_accessor :skip_callbacks

  attr_accessible :status, :closed_date, :invoice_date, :patient_id, :comment, :provider_id,
                  :payment_amount, :total_amount, :balance_owed, :invoiced, :invoiced_id,
                  :late_amount, :adjustment_description, :adjustment_amount, :balance_bill_sessions_attributes,
                  :created_user, :updated_user, :deleted,
                  :unformatted_closed_date,  # used for datepicker 
                  :unformatted_invoice_date,  # used for datepicker
                  :skip_callbacks
                  
  attr_accessor :unformatted_invoice_date, :unformatted_closed_date


  validates :status, :presence => true
  validates :patient_id, :presence => true
  validates :provider_id, :presence => true
  validates :invoiced, :inclusion => {:in => [true, false]}
  
  validates :created_user, :presence => true
  validates :deleted, :inclusion => {:in => [true, false]}


  # override the destory method to set the deleted boolean to true.
  def destroy
    run_callbacks :destroy do                   
      self.update_column(:deleted, true)     
    end
  end   

    
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
    
  # is the record in an editable state.  returns true if it is editable
  def editable_state?
    BalanceBillFlow.editable_state?(self)
  end
    
  # is the record in a deletable state.  returns true if it is deletable
  def deleteable?
    BalanceBillFlow.record_deleteable?(self)
  end
  
  # is the record in the initial state.  returns true if it is in initiate state
  def initial_status?
    BalanceBillFlow.initial_status?(self)
  end
  
  def ready?
    BalanceBillFlow.ready?(self)
  end


  # create the history record whenever the balance bill status is updated
  def create_history_record
    begin          
      history = self.balance_bill_histories.new(:status => self.status, :status_date => DateTime.now,                    
                :created_user => (self.updated_user.blank? ? self.created_user : self.updated_user))
      history.save
    rescue
      errors.add :base, "Failed to create the balance bill history record"          
      return false
    end
    return true
  end


  def build_balance_bill
    # if status is nil then this is a new record and need to build out the balance_bill
    if !self.status
      self.status = BalanceBillFlow::INITIATE
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
  end

    
  #
  # updates the total amounts, the balance bill session records and history
  #
  def update_balance_bill
    @state = true
    
    @total = 0.0
    # sum up the totals for all the sessions
    self.balance_bill_sessions.each do |session|
      @total += session.total_amount if session.status == BalanceBillFlow::INCLUDE
    end    
    # update the total amount due
    self.total_amount = @total + self.adjustment_amount + self.late_amount
    # sum up the payments
    @payment = 0
    self.balance_bill_payments.each do |payment|
      @payment += payment.payment_amount
    end
    self.payment_amount = @payment
    #calculate the balance due
    self.balance_owed = self.total_amount - self.payment_amount
    
    return @state
  end
    
  #
  # validate the data has certain fields, otherise set an error.  
  #
  def validate_data
    @state = true
    
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
    self.transaction do
      if @s.count > 0
        Dataerror.store(@s)
        @state = false
      end  
      
      # if everything is ggod, then set to ready and update history
      if @state
        self.update_column(:status, BalanceBillFlow::READY)
        create_history_record
      end      
    end
    
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
      self.balance_bill_sessions.each do |session|
        if session.status == BalanceBillFlow::INCLUDE
          @count += session.dataerrors.count
          @count += session.insurance_session.dataerrors.count
          @count += session.provider.dataerrors.count   
          @count += session.group.dataerrors.count if !session.group.blank?
        end        
      end
        
      self.transaction do
        # update the errors, error_count and status fields without validations
        if @count > 0                   
          self.update_column(:dataerror, true)
          self.update_column(:dataerror_count, @count)
          if self.status != BalanceBillFlow::INITIATE
            self.update_column(:status, BalanceBillFlow::INITIATE) 
            create_history_record
          end  
        else
          self.update_column(:dataerror, false)
          self.update_column(:dataerror_count, 0)
          if self.status != BalanceBillFlow::READY # dont reset status if already in ready state; dont create duplicate history record            
            self.update_column(:status, BalanceBillFlow::READY)
            create_history_record
          end
        end
      end  # end transaction
  end   # end validate_balance_bill


  #
  # when deleting a balance bill, need to reset the balance bill session records
  #
  def reset_balance_bill_sessions
    self.balance_bill_sessions.each do |session|
      session.balance_bill_id = nil
      session.status = BalanceBillFlow::INCLUDE
      session.save!      
    end
  end
end
