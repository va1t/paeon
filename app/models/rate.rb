class Rate < ActiveRecord::Base
    belongs_to :rateable, :polymorphic => true    
    has_many :dataerrors, :as => :dataerrorable, :dependent => :destroy
    
    #default scope hides records marked deleted
    default_scope where(:deleted => false) 
  
    before_validation :format_currency
    after_save :validate_data
    
    attr_accessible :rateable_type, :rateable_id, :cpt_code, :description, :rate, :unformatted_rate,
                    :created_user, :updated_user, :deleted
  
    attr_accessor :unformatted_rate
    
    validates :deleted, :inclusion => {:in => [true, false]}
    validates :created_user, :presence => true
  
  
    # override the destory method to set the deleted boolean to true.
    def destroy
      run_callbacks :destroy do    
        self.update_column(:deleted, true)
      end
    end    
      
    def rate_name
      "$#{rate}, #{cpt_code}, #{description}"
    end            

    #
    # For the autonumeric jquery plugin to work across browsers, needed to input into a text_field
    # This function strips out everything except numbers and decmial from the input string 
    def format_currency
      self.rate = self.unformatted_rate.gsub(/[^0-9.]/, '') if !self.unformatted_rate.blank?
    end 

    # check_data is a validation routine for the claim to ensure each session record is ready for submission
    # returns a message array of errors.  if no errors it returns an empty array.   
    # each model checks the fields within itself for completeness.
    # insurance billing has the ties to all the various records for a claim and can check all relationships required.  
    def validate_data
      #first remove any old errors from the table
      self.dataerrors.clear
      
      @s = []       
      # check the necessary fields in the table
      # use the build method so the polymorphic reference is generated cleanly
      @s.push self.dataerrors.build(:message => "A Rate must be entered", :created_user => self.created_user) if self.rate.blank?
      
            
      #if there are errors, save them to the dataerrors table and return false
      if @s.count > 0
        Dataerror.store(@s) 
        return false
      end
      #everything is good, return true
      return true
    end
  
end
