class DataerrorController < ApplicationController
  # user must be logged into the system
  before_filter :authenticate_user!  
  authorize_resource
  
  # display the list of dataerrors for the calling object
  # plus display the errors for any related tables
  # variables that singular, there is only one entry
  # variables that are plural will be arrays of similar type.  plus they will be join with the original table to provide identifying information.
  def index
    @dataerrorable, @name = find_polymorphic
    
    case @name
    when "Patient"
      @patient = @dataerrorable
      @patient_id = @patient.id
      @err_patient = @patient.dataerrors     
    when "Group"
      @group =  @dataerrorable
      @selector = Selector::GROUP
      @group_id = @group.id
    when "Provider"
      @provider =  @dataerrorable
      @selector = Selector::PROVIDER
      @provider_id = @provider.id
    when "Insurance_session"
      @insurance_session = @dataerrorable
      @selector = @insurance_session.selector
      @patient_id = @insurance_session.patient_id
      @group_id = @insurance_session.group_id
      @provider_id = @insurance_session.provider_id

      @err_insurance_session = @insurance_session.dataerrors
      @err_patient = @insurance_session.patient.dataerrors      
      @err_provider = @insurance_session.provider.dataerrors      
      @err_patient_injury = @insurance_session.patient_injury ? @insurance_session.patient_injury.dataerrors : nil
      @err_office = @insurance_session.office ? @insurance_session.office.dataerrors : nil
      @err_group = @insurance_session.group ? @insurance_session.group.dataerrors : nil
      # get systeminfo errors, if the record doesnt exist then set to one to flag the error 
      @err_systeminfo = SystemInfo.first ? SystemInfo.first.dataerrors : 1  
    end
  end
  
  
  #
  # GET /insurance_billings/1/dataerror
  # displays all the errors associated to a specific insurance claim
  #
  def insurance_billing_index
      @dataerrorable, @name = find_polymorphic
      respond_to do |format|
        if @name == "Insurance_billing"
          @insurance_billing = @dataerrorable
          @session = InsuranceSession.find(@insurance_billing.insurance_session_id)
    
          @err_insurance_billing = @insurance_billing.dataerrors      
          #session specific relationships and errors
          @err_insurance_session = @session.dataerrors
          @err_patient_injury = @session.patient_injury ? @session.patient_injury.dataerrors : nil          
          @err_managed_care = @insurance_billing.managed_care ? @insurance_billing.managed_care.dataerrors : nil
          if !@insurance_billing.subscriber.blank?
            @err_subscriber = @insurance_billing.subscriber.dataerrors       
            
            @err_insurance_company = @insurance_billing.subscriber.insurance_company ? @insurance_billing.subscriber.insurance_company.dataerrors : nil
          else
            @err_subscriber = nil
            @err_insurance_company = nil
          end          
               
          @err_patient = @insurance_billing.patient.dataerrors      
          @err_provider = @insurance_billing.provider.dataerrors      
          @err_office = @session.office ? @session.office.dataerrors : nil
          @err_group = @session.group ? @session.group.dataerrors : nil               
          # get systeminfo errors, if the record doesnt exist then set to one to flag the error 
          @err_systeminfo = SystemInfo.first ? SystemInfo.first.dataerrors : 1
          format.html  
        else
          #there was an error in how the user got to this screen
          notice = "Error in selecting insurance billing data errors."
          format.html { redirect_to home_index, notice: notice }
        end
        format.json { head :no_content }
      end    
  end


  # GET /insurance_billing/1/dataerror/override
  # allows the claim state to be overridden so the user can directly submit the claim
  def insurance_billing_override
    @dataerrorable, @name = find_polymorphic
    #check the state of the claim
    # if the claim does not have a provider, patient, subscriber or insurance associated
    # do not allow the claim to be overridden
    @insurance_billing = @dataerrorable
    @session = InsuranceSession.find(@insurance_billing.insurance_session_id)
    
    # if there is no patient_id, provider_id, subscriber_id or insurance_company_id, then do not update the 
    # status and redirect to an error page. 
    @overrideable = true
    @override_message = []
    if @insurance_billing.provider_id.blank?
      @overrideable = false
      @override_message.push "There is no provider associated with the claim."
    end
    if @insurance_billing.patient_id.blank?
      @overrideable = false
      @override_message.push "There is no patient associated with the claim.  Someone deleted the patient!"      
    end
    if @insurance_billing.subscriber_id.blank?
      @overrideable = false
      @override_message.push "There is no subscriber insurance associated to the claim.  The insurance company has not been identified for payment."
    end
    if @insurance_billing.insurance_company_id.blank?
      @overrideable = false
      @override_message.push "The insurance company listed by the subscriber is not entered into the system.  The insurance company may have been deleted."
    end
    
    respond_to do |format|
    # normally set the insurance_billing state to ready and redirect to dataerror#insurance_billing_index
      if @overrideable        
        #set the insurance_billing status to ready  
        @insurance_billing.override_status(current_user.login_name)     
        format.html { redirect_to insurance_sessions_path, notice: "Status has been overridden." }
      else
        #dont change the state and redirect to the error page.
        format.html
      end
       format.json { head :no_content } 
    end
    
  end
  

  def balance_bill_index
    @dataerrorable, @name = find_polymorphic
    @balance_bill = @dataerrorable
    # get the errors
    @err_balance_bill = @balance_bill.dataerrors
    @err_patient = @balance_bill.patient.dataerrors
    
    # capture the errors as an array 
    @err_balance_bill_sessions = []
    # loop through the balance bill sessions and pull the errors.
    @balance_bill.balance_bill_sessions.each do |session|
      err_session     = session.dataerrors 
      err_ins_session = session.insurance_session.dataerrors
      err_provider    = session.provider.dataerrors
      err_group       = session.group ? session.group.dataerrors : [] 
          
      @err_balance_bill_sessions.push :err_session => err_session.count != 0 ? true : false,         :err_session_msg => err_session, 
                                       :err_ins_session => err_ins_session.count != 0 ? true : false, :err_ins_session_msg => err_ins_session,
                                       :err_provider => err_provider.count != 0 ? true : false,       :err_provider_msg => err_provider,
                                       :err_group => err_group.count != 0 ? true : false,             :err_group_msg => err_group,
                                       :insurance_session_id => session.insurance_session_id,
                                       :balance_bill_session_id => session.id
    end

    respond_to do |format|
      format.html
      format.json { head :no_content }   
    end
  end
  
end
