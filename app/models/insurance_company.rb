class InsuranceCompany < ActiveRecord::Base
  
   has_many :subscribers
   has_many :provider_insurances
   has_many :dataerrors, :as => :dataerrorable, :dependent => :destroy
   
   #default scope hides records marked deleted
   default_scope where(:deleted => false)
      
   after_save :validate_data
   
   attr_accessible :name, :address1, :address2, :city, :state, :zip,  
                   :main_phone, :main_phone_description, :alt_phone, :alt_phone_description, 
                   :fax_number, :insurance_co_id, :submitter_id, 
                   :created_user, :updated_user, :deleted
                  
   MAX_LENGTH = 100

   validates :name, :presence => true, :length => {:minimum => STRING_MIN_LENGTH, :maximum => STRING_LRG_LENGTH }
   validates :address1, :length => {:minimum => STRING_MIN_LENGTH, :maximum => STRING_LRG_LENGTH }
   validates :address2, :length => {:maximum => STRING_LRG_LENGTH }, :allow_nil => true, :allow_blank => true
   validates :city, :length => {:minimum => STRING_MIN_LENGTH, :maximum => STRING_MED_LENGTH }
   validates :state, :length => {:minimum => STRING_MIN_LENGTH, :maximum => STRING_SML_LENGTH }                   
   validates :zip, :format => {:with => REGEX_ZIP },
                   :length => {:minimum => ZIP_MIN_LENGTH, :maximum => ZIP_MAX_LENGTH }

   validates :main_phone, :format => {:with => REGEX_PHONE }, :allow_nil => true, :allow_blank => true, 
                          :length => {:maximum => STRING_LRG_LENGTH }  
   validates :alt_phone, :format => {:with => REGEX_PHONE }, :allow_nil => true, :allow_blank => true,                  
                         :length => {:maximum => PHONE_MAX_LENGTH }
   validates :fax_number, :format => {:with => REGEX_PHONE }, :allow_nil => true, :allow_blank => true,                  
                         :length => {:maximum => PHONE_MAX_LENGTH }

   validates :main_phone_description, :length => {:maximum => 50}, :allow_nil => true, :allow_blank => true                         
   validates :alt_phone_description, :length => {:maximum => 50}, :allow_nil => true, :allow_blank => true
   
   validates :insurance_co_id, :length => {:maximum => MAX_LENGTH }, :allow_nil => true, :allow_blank => true
   validates :submitter_id, :length => {:maximum => MAX_LENGTH }, :allow_nil => true, :allow_blank => true
   
   validates :deleted, :inclusion => {:in => [true, false]}
   validates :created_user, :presence => true
   

    def display_name
      "#{name}, #{address1}, #{city}, #{state}"
    end
    
    def company_name
      return name ? "#{name}" : "Not Selected"      
    end
     
    # override the destory method to set the deleted boolean to true.
    def destroy      
      if !self.subscribers.blank?
        errors.add :base, "There are patient insured dependencies for #{self.name}. Deletion is not allowed"        
      elsif !self.provider_insurances.blank?
        errors.add :base, "There are provider insurance dependencies for #{self.name}. Deletion is not allowed"        
      else        
        run_callbacks :destroy do
          self.update_column(:deleted, true)
        end  
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
      @s.push self.dataerrors.build(:message => "Insurance Company name is required", :created_user => self.created_user) if self.name.blank? 
      @s.push self.dataerrors.build(:message => "Payor ID is required", :created_user => self.created_user) if self.insurance_co_id.blank?
      @s.push self.dataerrors.build(:message => "An Address is required", :created_user => self.created_user) if self.address1.blank?
      @s.push self.dataerrors.build(:message => "A city is required as part of the address", :created_user => self.created_user) if self.city.blank?
      @s.push self.dataerrors.build(:message => "The state is reuqired as part oof the address", :created_user => self.created_user) if self.state.blank?
      @s.push self.dataerrors.build(:message => "The zip code is required", :created_user => self.created_user) if self.zip.blank?
            
      #if there are errors, save them to the dataerrors table and return false
      if @s.count > 0
        Dataerror.store(@s) 
        @state = false
      end
      # if the error counts changed, then update all subsciber and provider_insurance records
      # they will in turn re-validate and update insurance_billing && balance_bill records
      if @original_count != @s.count
        self.subscribers.each { |subscribe| subscribe.validate_data }
        self.provider_insurances.each { |provide| provide.validate_data }
      end             
      return @state
    end
   
end
