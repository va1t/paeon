class ProviderInsurance < ActiveRecord::Base
  
  belongs_to :providerable, :polymorphic => true
  belongs_to :insurance_company
  has_many :dataerrors, :as => :dataerrorable, :dependent => :destroy
  
  before_validation :format_date
  after_save :validate_data
  
  #default scope hides records marked deleted
  default_scope where(:deleted => false)
  
  attr_accessible :providerable_id, :providerable_type, :insurance_company_id, :provider_id, 
                  :expiration_date, :notification_date, :effective_date, :notes, :ein_suffix,
                  :unformatted_expiration, :unformatted_notification, :unformatted_effective, # for the date jscript popup
                  :created_user, :updated_user, :deleted
  
  attr_accessor   :unformatted_expiration, :unformatted_notification, :unformatted_effective
  
  MAX_LENGTH = 75
    
  validates :insurance_company_id, :presence => true, :numericality => {:only_integer => true}
  
  validates :provider_id, :length => {:maximum => MAX_LENGTH }
  #validates :expiration_date, :date => {:before => Proc.new {Time.now + 3.years}, :message => I18n.translate('errors.provider_insurance.expiration_date')}
            
  validates :notification_date, :allow_nil => true, :allow_blank => true, 
            :date => {:before => :expiration_date, :message => I18n.translate('errors.provider_insurance.notification_date')}
             
  validates :deleted, :inclusion => {:in => [true, false]}
  validates :created_user, :presence => true

    
    # override the destory method to set the deleted boolean to true.
    def destroy
      run_callbacks :destroy do    
        self.update_column(:deleted, true)
      end
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
      @s.push self.dataerrors.build(:message => "An insurance company must be selected", :created_user => self.created_user) if self.insurance_company_id
      @s.push self.dataerrors.build(:message => "A provider identifer must be supplied", :created_user => self.created_user) if self.provider_id
      @s.push self.dataerrors.build(:message => "An expiration date is required", :created_user => self.created_user) if self.expiration_date
            
      #if there are errors, save them to the dataerrors table and return false
      if @s.count > 0
        Dataerror.store(@s) 
        @state = false
      end
     
      return @state
    end  
    
    
    def self.group_provider_insurance(pid)
      self.find(:all, :select => "provider_insurances.id, provider_insurances.group_id, provider_insurances.insurance_company_id, 
                provider_insurances.provider_id, groups.group_name, provider_insurances.expiration_date, provider_insurances.notification_date, 
                insurance_companies.name",
                :joins => [:group, :insurance_company], :conditions => ["provider_insurances.group_id = ?", pid] )
    end
  
  
    def self.provider_provider_insurance(pid)
      self.find(:all, :select => "provider_insurances.id, provider_insurances.provider_id, provider_insurances.insurance_company_id, 
                provider_insurances.provider_id, providers.last_name, providers.first_name, provider_insurances.expiration_date, provider_insurances.notification_date, 
                insurance_companies.name",
                :joins => [:provider, :insurance_company], :conditions => ["provider_insurances.provider_id = ?", pid] )  
    end
    
    def self.all_group_insurance
      self.find(:all, :select => "provider_insurances.id, provider_insurances.group_id, provider_insurances.insurance_company_id, 
                provider_insurances.provider_id, groups.group_name, provider_insurances.expiration_date, provider_insurances.notification_date, 
                insurance_companies.name",
                :joins => [:group, :insurance_company], :order => 'groups.group_name') 
    end
    
    
    def self.all_provider_insurance
      self.find(:all, :select => "provider_insurances.id, provider_insurances.provider_id, provider_insurances.insurance_company_id, 
                provider_insurances.provider_id, providers.last_name, providers.first_name, provider_insurances.expiration_date, provider_insurances.notification_date, 
                insurance_companies.name",
               :joins => [:provider, :insurance_company], :order => 'providers.last_name')  
    end
    
    private
    
    # reformat the date of service from m/d/y to y/m/d for sotring in db
    def format_date
      begin
        if !self.unformatted_expiration.blank?
          self.expiration_date = Date.strptime(self.unformatted_expiration, "%m/%d/%Y").to_time(:utc)
        end
        if !self.unformatted_notification.blank?
          self.notification_date = Date.strptime(self.unformatted_notification, "%m/%d/%Y").to_time(:utc)
        end
        if !self.unformatted_effective.blank?
          self.effective_date = Date.strptime(self.unformatted_effective, "%m/%d/%Y").to_time(:utc)
        end
      rescue
        errors.add :base, "Invalid Date(s)"
        return false
      end
    end
    
end
