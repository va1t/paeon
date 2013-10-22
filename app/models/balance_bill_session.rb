class BalanceBillSession < ActiveRecord::Base
    
    belongs_to :balance_bill
    belongs_to :insurance_session
    belongs_to :patient
    belongs_to :provider
    belongs_to :group
                
    has_many :balance_bill_details, :dependent => :destroy
    accepts_nested_attributes_for :balance_bill_details, :allow_destroy => true
    
    has_many :dataerrors, :as => :dataerrorable, :dependent => :destroy
    
    #default scope hides records marked deleted
    default_scope where(:deleted => false)
     
    # select all the balance bill sessions not associated to a balance bill and unique patients.
    scope :pending, :conditions => ["balance_bill_sessions.balance_bill_id IS ?", nil], 
                    :include => [:patient],
                    :order => ["patients.last_name DESC"]

    scope :patient_pending, lambda { |patient_id| { 
                    :conditions => ["balance_bill_sessions.balance_bill_id IS ? and balance_bill_sessions.patient_id = ?", nil, patient_id],
                    :include => [:provider, :group]
                    }}

    after_initialize :build_balance_bill_session
    before_validation :update_balance_bill_details, :unless => :skip_callbacks
    after_save :update_session, :unless => :skip_callbacks
    after_save :validate_data, :unless => :skip_callbacks
    
    # allows the skipping of callbacks to save on database loads  
    # use InsuranceBilling.skip_callbacks = true to set, or in update_attributes(..., :skip_callbacks => true)
    cattr_accessor :skip_callbacks
    
    attr_accessible :dos, :patient_id, :group_id, :provider_id, :payment_amount, :total_amount, :status,       
                    :created_user, :updated_user, :deleted,
                    :balance_bill_details_attributes, # for accepting balance_bill_details records                    
                    :skip_callbacks
                    
    validates :status, :presence => true
    validates :patient_id, :presence => true
    validates :provider_id, :presence => true

    validates :created_user, :presence => true
    validates :deleted, :inclusion => {:in => [true, false]}
    
    # override the destory method to set the deleted boolean to true.
    def destroy
      run_callbacks :destroy do                   
        self.update_column(:deleted, true)
        self.insurance_session.update_attributes(:status => SessionFlow::ERROR) if self.insurance_session.balance_bills.count == 0
      end
    end   
    
    #
    # build the balance bill session record and the first detail record
    #
    def build_balance_bill_session
      # if patient_id is not set, then new record. need to build out the defualt fields
      if !self.patient_id?
        self.patient_id = self.insurance_session.patient_id
        self.group_id =  self.insurance_session.group_id
        self.provider_id =  self.insurance_session.provider_id        
        self.dos = self.insurance_session.dos
        self.status = BalanceBillFlow::INCLUDE
        # the balance_due is set from the session's balance_owed.  if null balance_owed, then set to 0.
        # on every balance bill update and/or ins billing update, the session charges are recalculated, so the balance_owed is accurate
        self.total_amount = self.insurance_session.balance_owed.blank? ? 0 : self.insurance_session.balance_owed
        self.payment_amount = 0
        
        #create the first detail record for the balance bill.
        self.balance_bill_details.new(:created_user => self.created_user, :amount => self.total_amount, :quantity => 1, 
                                      :description => "Balance owed for date of service: #{self.dos.strftime("%m/%d/%Y")}")
      end
    end

    # update the associated session status
    def update_session
      self.insurance_session.update_column(:status, SessionFlow::BALANCE) if !self.insurance_session.blank?
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
        self.total_amount += detail.amount.to_f if detail.amount?
      end      
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
        self.transaction do
          if @s.count > 0
            Dataerror.store(@s)
            #update the dataerror attributes 
            return false  
          end          
        end
      rescue
        errors.add :base, "failed to validate balance billing record"
        return false
      end
      return true   #everything is good, return true
    end

end
