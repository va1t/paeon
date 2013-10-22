class PatientInjury < ActiveRecord::Base
    belongs_to :patients
    has_many :insurance_sessions
    has_many :dataerrors, :as => :dataerrorable, :dependent => :destroy
    
    #default scope hides records marked deleted
    default_scope where(:deleted => false)
    
    before_validation :format_date
    after_save :validate_data
    
    attr_accessible :patient_id, :description, :start_illness, :start_therapy, 
                    :accident_type, :accident_description, :accident_state, 
                    :disability_start, :disability_stop, :hospitalization_start, :hospitalization_stop,
                    :unable_to_work_start, :unable_to_work_stop, 
                    :created_at, :updated_at, :created_user, :updated_user, :deleted,
                    # attributes below are virtual attribute for datepicker
                    :unformatted_start_illness, :unformatted_start_therapy, :unformatted_hospitalization_start,
                    :unformatted_hospitalization_stop, :unformatted_disability_start, :unformatted_disability_stop,
                    :unformatted_unable_work_start, :unformatted_unable_work_stop
    
    attr_accessor   :unformatted_start_illness, :unformatted_start_therapy, :unformatted_hospitalization_start,
                    :unformatted_hospitalization_stop, :unformatted_disability_start, :unformatted_disability_stop,
                    :unformatted_unable_work_start, :unformatted_unable_work_stop
                    
    MAX_LENGTH = 50
    
    validates :patient_id, :presence => true, :numericality => {:only_integer => true}
    #validates :description,   :presence => true
    
    validates :accident_type, :length => { :maximum => MAX_LENGTH }
    validates :accident_description, :presence => {:message => I18n.translate('errors.patient_injury.accident_description')}, :if => :accident_other            
    validates :accident_state, :presence => {:message => I18n.translate('errors.patient_injury.accident_state')}, :if => :accident
      
    validates :start_illness, :date => {:before => Proc.new {Time.now}, 
              :message => I18n.translate('errors.patient_injury.start_illness') }  
    validates :start_therapy, :date => {:before => Proc.new {Time.now}, :after_or_equal_to => :start_illness, 
              :message => I18n.translate('errors.patient_injury.start_therapy') }  
    
    validates :hospitalization_start, :allow_nil => true, :allow_blank => true, 
              :date => {:before => Proc.new {Time.now}, :after_or_equal_to => :start_illness, 
                        :message => I18n.translate('errors.patient_injury.start_date', :name => "Hospitalization")}
    validates :hospitalization_stop, :allow_nil => true, :allow_blank => true,  
              :date => {:before => Proc.new {Time.now}, :after => :hospitalization_start, 
                        :message => I18n.translate('errors.patient_injury.stop_date', :name => "Hospitalization")}
    
    validates :disability_start, :allow_nil => true, :allow_blank => true, 
              :date => {:before => Proc.new {Time.now}, :after_or_equal_to => :start_illness, 
                        :message => I18n.translate('errors.patient_injury.start_date', :name => "Disability")}
    validates :disability_stop, :allow_nil => true, :allow_blank => true, 
              :date => {:before => Proc.new {Time.now}, :after => :disability_start, 
                        :message => I18n.translate('errors.patient_injury.stop_date', :name => "Disability")}
  
    validates :unable_to_work_start, :allow_nil => true, :allow_blank => true, 
              :date => {:before => Proc.new {Time.now}, :after_or_equal_to => :start_illness, 
                        :message => I18n.translate('errors.patient_injury.start_date', :name => "Unable to Work")}
    validates :unable_to_work_stop, :allow_nil => true, :allow_blank => true, 
              :date => {:before => Proc.new {Time.now}, :after => :unable_to_work_start, 
                        :message => I18n.translate('errors.patient_injury.stop_date', :name => "Unable to Work")}
    
    validates :deleted, :inclusion => {:in => [true, false]}
    validates :created_user, :presence => true
        
        
    # override the destory method to set the deleted boolean to true.
    def destroy
      if !self.insurance_sessions.blank?
        # record is used in an insurance_session, dont allow deletion
        errors.add :base, "Patient insured record is used within session, deletion is not allowed."
      else
        run_callbacks :destroy do    
          self.update_column(:deleted, true)
        end  
      end
    end
    
    def display_history
      "#{self.start_illness.strftime("%m/%d/%Y")}, #{self.description}"
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
      @s.push self.dataerrors.build(:message => "Date therapy started is required", :created_user => self.created_user) if self.start_therapy.blank?
      @s.push self.dataerrors.build(:message => "Date when illness started is required", :created_user => self.created_user) if self.start_illness.blank?
      # if accident, then the accident state is required
      if self.accident_type == :accident
        @s.push self.dataerrors.build(:message => "The state where the accident occured is required", :created_user => self.created_user) if self.accident_state.blank?
      end

      #if there are errors, save them to the dataerrors table and return false
      if @s.count > 0
        Dataerror.store(@s) 
        @state = false
      end
      #if the error counts changed, then update all insurance_bill & balance bills
      if @original_count != @s.count
        self.insurance_sessions.each { |session| session.save! }        
      end 
      return @state
    end


    # reformat the dates from m/d/y to y/m/d for storing in db
    def format_date      
      begin
        if !self.unformatted_start_illness.blank?
          self.start_illness = Date.strptime(self.unformatted_start_illness, "%m/%d/%Y").to_time(:utc)
        end
        if !self.unformatted_start_therapy.blank?
          self.start_therapy = Date.strptime(self.unformatted_start_therapy, "%m/%d/%Y").to_time(:utc)
        end
        if !self.unformatted_hospitalization_start.blank?
          self.hospitalization_start = Date.strptime(self.unformatted_hospitalization_start, "%m/%d/%Y").to_time(:utc)
        end
        if !self.unformatted_hospitalization_stop.blank?
          self.hospitalization_stop = Date.strptime(self.unformatted_hospitalization_stop, "%m/%d/%Y").to_time(:utc)
        end
        if !self.unformatted_disability_start.blank?
          self.disability_start = Date.strptime(self.unformatted_disability_start, "%m/%d/%Y").to_time(:utc)
        end
        if !self.unformatted_disability_stop.blank?
          self.disability_stop = Date.strptime(self.unformatted_disability_stop, "%m/%d/%Y").to_time(:utc)
        end
        if !self.unformatted_unable_work_start.blank?
          self.unable_to_work_start = Date.strptime(self.unformatted_unable_work_start, "%m/%d/%Y").to_time(:utc)
        end
        if !self.unformatted_unable_work_stop.blank?
          self.unable_to_work_stop = Date.strptime(self.unformatted_unable_work_stop, "%m/%d/%Y").to_time(:utc)
        end
      rescue
        errors.add :base, "Invalid Date(s)"
        return false
      end
    end

    
    private 

    
    def accident
      self.accident_type != AccidentType::ACCIDENT_TYPE_NOT
    end
    
    def accident_other
      # in lieu of using a method could also use a proc
      #Proc.new {|ch| ch.accident_type == "Other"}
      self.accident_type == AccidentType::ACCIDENT_TYPE_OTHER
    end
end
