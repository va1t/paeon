#
# Managed care records are the insurance authorizations
# Primary relationship is to subscriber.  Patient relationship is included to simplfy the queries
#
class ManagedCare < ActiveRecord::Base
  
    belongs_to :subscriber    
    belongs_to :patient
    has_many :insurance_billings
    has_many :dataerrors, :as => :dataerrorable, :dependent => :destroy
    
    #default scope hides records marked deleted
    default_scope :conditions => ["managed_cares.deleted = ?", false], :order => "managed_cares.active DESC" 
    
    # minimum numbers before the warning scope returns 
    WARNING_SESSION = 3
    
    #pulls the managed care records that have active dates for a specific patient
    scope :active, lambda {|patient| where("patient_id = ? and start_date <= ? and end_date >= ?", patient, DateTime.now, DateTime.now) }
    
    scope :warning, :conditions => ["managed_cares.authorized_sessions - managed_cares.used_sessions <= ?", WARNING_SESSION]  
    
    before_validation :format_date
    before_save :update_values
    after_save :validate_data
    
    attr_accessible :patient_id, :subscriber_id, :start_date, :end_date, :authorization_id, :authorized_sessions, :authorized_units, :authorized_charges,  
                    :used_sessions, :used_units, :used_charges, :copay, :active,
                    :created_user, :updated_user, :deleted,
                    :unformatted_start_date, :unformatted_end_date #for use with datepicker
                    
    attr_accessor   :unformatted_start_date, :unformatted_end_date
         
    MAX_LENGTH = 50
    
    validates :patient_id, :presence => true
    validates :subscriber_id, :presence => true
    #validates :authorization_id, :presence => true
    
    # use unless clause so the date validations are not trigger when the delete attribute is updated.
    validates :start_date, :date => {:before => Proc.new {Time.now}, 
                           :message => I18n.translate('errors.managed_care.start_date')}, :unless => :deleted            
    validates :end_date,   :date => {:after => :start_date, 
                           :message => I18n.translate('errors.managed_care.end_date')}, :unless => :deleted
    
    validates :authorized_units, :length => {:maximum => MAX_LENGTH }
    validates :used_units, :length => {:maximum => MAX_LENGTH }
    
    validates :active, :inclusion => {:in => [true, false]}
    validates :deleted, :inclusion => {:in => [true, false]}
    validates :created_user, :presence => true
     
     
    # override the destory method to set the deleted boolean to true.
    def destroy
      if !self.insurance_billings.blank?
        #cant delete the record 
        errors.add :base, "This managed care record is associated to a session.  It cannot be deleted."
      else
        run_callbacks :destroy do      
          self.update_column(:deleted, true)
        end  
      end
    end    

    # reformat the start & end dates from m/d/y to y/m/d for storing in db
    def format_date      
      begin
        if !self.unformatted_start_date.blank?
          self.start_date = Date.strptime(self.unformatted_start_date, "%m/%d/%Y").to_time(:utc)
        end
        if !self.unformatted_end_date.blank?
          self.end_date = Date.strptime(self.unformatted_end_date, "%m/%d/%Y").to_time(:utc)
        end
      rescue
        errors.add :base, "Invalid Date(s)"
        return false
      end
    end
    
    def manage_care_identifier
      @current_state = self.active ? "Active" : "Not Active"
      @insurance_name = self.subscriber.insurance_company.name
      "#{self.authorization_id}, #{self.subscriber.subscriber_name}, #{@current_state}, #{@insurance_name}"
    end

    def update_values
      #set default values for the authorized charges unles they have already been entered
      self.authorized_sessions ||= 0
      self.authorized_units    ||= 0
      self.authorized_charges  ||= 0

      # select all ins session records that have this managed care id
      # always recalculate the unit / session charges on save.  
      @insurance_billings = self.insurance_billings
      # initalize the variables to zero     
      @session = 0; @units = 0; @charges = 0
      # loop through each session / each ins billing / each managed care and sum up
      # always start at zero and re-sum everything to be sure that all changes are included.
      @insurance_billings.each do |billing|        
        # if the clim was closed for resubmittion then dont deduct the used amounts
        if billing.status != BillingFlow::CLOSED_RESUBMIT
          @iprocedures = billing.iprocedures
          #loop through and sum the units, session and totals
          @iprocedures.each do |iproc|
            @session += iproc.sessions ? iproc.sessions : 0
            @units   += iproc.units ? iproc.units : 0                
            @charges += iproc.total_charge ? iproc.total_charge : 0 
          end
        end
      end
      # if there are no authorize charges then the used charges stay at zero            
      if self.authorized_charges.blank? || self.authorized_charges == 0
         @charges = 0
      end 
      #store the updates into the managed care record
      self.used_sessions = @session      
      self.used_units    = @units
      self.used_charges  = @charges
    end
    

    # check_data is a validation routine for the claim to ensure each session record is ready for submission
    # returns a message array of errors.  if no errors it returns an empty array.   
    # each model checks the fields within itself for completeness.
    # insurance billing has the ties to all the various records for a claim and can check all relationships required.  
    def validate_data
      @state = true
      #store the original error count, if there is a chnage to the count, then we want to update all associated insurance_billings and balance_bills
      @original_count = self.dataerrors.count
      #first remove any old errors from the table
      self.dataerrors.clear
      
      @s = []       
      # check the necessary fields in the table
      # use the build method so the polymorphic reference is generated cleanly
      @s.push self.dataerrors.build(:message => "Start date for managed care needs to be entered", :created_user => self.created_user) if self.start_date.blank?
      @s.push self.dataerrors.build(:message => "Authorization ID must be entered", :created_user => self.created_user) if self.authorization_id.blank?
            
      #if there are errors, save them to the dataerrors table and return false
      if @s.count > 0
        Dataerror.store(@s) 
        @state = false
      end
      #if the error counts changed, then update all insurance_sessions, which in tuen will update insurance billings and balance bills
      self.insurance_sessions.each { |session| session.validate_data } if @original_count != @s.count        

      return @state
    end  
end
