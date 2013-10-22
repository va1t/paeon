class InsuranceBillingsController < ApplicationController
  # user must be logged into the system
  before_filter :authenticate_user! 
  authorize_resource
  
  # GET /insurance_billings
  # GET /insurance_billings.json
  # the insurance claims tied to a session are all displayed and editted through this method
  # there can only be one claim active at a time
  def index        
    @insurance_session = InsuranceSession.find(params[:insurance_session_id], :joins => :provider, :include => :group)
    setup_session
    
    # if there are no insurance billings agaisnt the session, and no balance bills, then create one.      
    if @insurance_session.insurance_billings.blank? && @insurance_session.verify_session_state
      # all new insurance billings are reated under the new method for consistency
      redirect_to new_insurance_session_insurance_billing_path(@insurance_session.id)
      return
    end
    setup_base_variables
    setup_codes                 # setup the diagnostic codes
    setup_rates_and_ein         # setup the rates for use in the procedures boxes
    @notes = @insurance_session.notes
    @secondary_status = SessionFlow::SECONDARY_STATUS
    
    @title = "Insurance Claims"    
    @display_sidebar = true
    
    respond_to do |format|    
        format.html # index.html.erb
        format.json { head :no_content }             
    end
  end
  
  
  # GET /insurance_billings/new
  # GET /insurance_billings/new.json
  # the new method creates additional claims agaisnt a session
  # the user is then redirected to the index page to display all claims 
  def new
    @insurance_session = InsuranceSession.find(params[:insurance_session_id])

    respond_to do |format|
        # verify that all claims and balance bills are closed before opening a new claim
        if @insurance_session.verify_session_state      
          # create the new claim
          @insurance_billing = @insurance_session.insurance_billings.new(:created_user => current_user.login_name, :status => BillingFlow::INITIATE, :patient_id => @insurance_session.patient_id, :provider_id => @insurance_session.provider_id )
          # insurance billing record is created through insurance sessions, so the insurance session create method is called 
          # the insurance_billing_history record will be created on create        
          if @insurance_billing.save!            
            # clone the cpt and diagnosis codes
            clone_procedure_diagnosis_codes(@insurance_session, @insurance_billing)  
            message = 'Insurance claim was successfully created.'
            format.html { redirect_to insurance_session_insurance_billings_path, notice: message }
          else                                        
            message = "InsuranceBilling: "            
            @insurance_billing.errors.full_messages.each {|msg| message += msg + ", "} if @insurance_billing.errors.any?
            format.html { redirect_to insurance_sessions_path, notice: message }                      
          end
        else
          message = "Session: "            
          @insurance_session.errors.full_messages.each {|msg| message += msg + ", "} if @insurance_session.errors.any?
          format.html { redirect_to insurance_sessions_path, notice: message }                      
        end      
        format.json { head :no_content }
    end
  end

  
  # PUT /insurance_billings/1
  # PUT /insurance_billings/1.json
  def update
    @insurance_billing = InsuranceBilling.find(params[:id])
    @insurance_session = InsuranceSession.find(@insurance_billing.insurance_session_id)
    @insurance_billing.updated_user = current_user.login_name   
                
    if params[:insurance_billing]
      #update the created and updated users for each iprocedures record   
      @iprocs = params[:insurance_billing][:iprocedures_attributes]    
      if @iprocs
        @iprocs.each do |x, p|
          p[:created_user] = current_user.login_name if p[:created_user].blank?
          p[:updated_user] = current_user.login_name if p[:updated_user].blank?
        end
      end
    end
    
    respond_to do |format|
      if @insurance_billing.update_attributes(params[:insurance_billing])
        logger.info "Saved the record"
        format.html {           
          if params[:commit] == "Update Claim"
            redirect_to insurance_session_insurance_billings_path  #redirect to the edit screen for the ins_billing record
          else
            redirect_to insurance_sessions_path, notice: 'Insurance billing was successfully updated.'  #redirect back to the ins_session index screen
          end
        }
        format.js { redirect_to insurance_billings_ajax_procedure_path(@insurance_billing) }
        format.json { head :no_content }
      else
        logger.info "Did not save the record"        
        
        format.html { 
            setup_base_variables
            setup_codes             # setup the diagnostic codes
            setup_rates_and_ein     # setup the rates for use in the procedures boxes
            render action: "index", notice: 'Insurance billing was not updated.' 
         }
        format.json { render json: @insurance_billing.errors, status: :unprocessable_entity }
      end
    end
  end


  # DELETE /insurance_billings/1
  # DELETE /insurance_billings/1.json
  def destroy
    @insurance_billing = InsuranceBilling.find(params[:id])
    @insurance_billing.updated_user = current_user.login_name
    @insurance_billing.destroy

    respond_to do |format|
        format.html { redirect_to insurance_session_insurance_billings_path(@insurance_billing.insurance_session_id) } #redirect back to the ins_session index screen
        format.json { head :no_content }
    end
  end
  
  
  def diagnostic_create
    @insurance_billing = InsuranceBilling.find(params[:insurance_billing_id])
    @diag = @insurance_billing.idiagnostics.build(params[:idiagnostic])
    @diag.created_user = current_user.login_name
    @diag_code = @insurance_billing.idiagnostics
    setup_diagnostic_variables(params[:idiagnostic][:selection])    

    respond_to do |format|
     @diag.save       
      if @diag.errors.any?
        @msg = ""
        @diag.errors.full_messages.each do |msg| 
          @msg += msg + "<br />"         
        end
      else
        @msg = "Diagnostic code created."
      end
      # execute these 2 statements after the save in case the value is not saved
      #need to rebuild the insurance_billing to make sure the cpt code, if not saved, is not brought over
      @insurance_billing = InsuranceBilling.find(params[:insurance_billing_id])
      @diag_code = @insurance_billing.idiagnostics      
      format.html {render :nothing => true }      
      format.js 
    end          
  end
  
  
  def diagnostic_delete
    @insurance_billing = InsuranceBilling.find(params[:insurance_billing_id])
    @idiagnostic = Idiagnostic.find(params[:id])
    @idiagnostic.destroy 
    
    @diag_code = @insurance_billing.idiagnostics
    @codes = CodesDsm.all
    @selection = "DSM"
    @msg = "Diagnostic code deleted."
    respond_to do |format|
      format.html {render :nothing => true }      
      format.js 
    end          
  end  
  
    
  # Get /insurance_billing/ajax_diagnosis
  # updates the diagnostics drop down box when slecting different radio buttons
  def ajax_diagnosis
    @diag = params[:idiagnostic]
    case @diag[:selection]
    when "ICD9"
      @codes = CodesIcd9.all
      @var = "icd9_code"
    when "ICD10"
      #@codes = CodesIcd10.all
      #@var = "icd10_code"
    when "DSM"
      @codes = CodesDsm.dsm
      @var = "dsm_code"
    when "DSM4"
      @codes = CodesDsm.dsm4
      @var = "dsm4_code"
    else #default ot DSM5
      @codes = CodesDsm.dsm5
      @var = "dsm5_code"
    end
    
    respond_to do |format|    
      format.js {render :layout => false }                   
    end
  end
    
  # Get /insurance_session/:insurance_session_id/insurance_billing/:insurance_billing_id/ajax_procedure
  # retreives the current set of iprocedures for the claim
  # builds a new record onto the set
  def ajax_procedure
    @insurance_billing = InsuranceBilling.find(params[:insurance_billing_id])
    @iprocedures = []
    if params[:insurance_billing]
      @attributes = params[:insurance_billing][:iprocedures_attributes]    
      params[:insurance_billing][:iprocedures_attributes].each do |key, value|
        @iprocedures.push @insurance_billing.iprocedures.build(value)
      end
    end
    @count = @insurance_billing.iprocedures.count
    @iprocedures.push @insurance_billing.iprocedures.build()   
    @insurance_session = InsuranceSession.find(@insurance_billing.insurance_session.id)
    #retreive the procedure codes    
    @cpt_codes = CodesCpt.all
    @modifiers = CodesModifier.all
    #setup the rates variable
    setup_rates_and_ein

    respond_to do |format|    
      format.js {render :layout => false }                   
    end
  end
  
  
  #
  # GET /secondary/:insurance_billing_id
  # closes the claim, updates session to secondary or tertiary then create new claim
  def secondary    
    @insurance_session = InsuranceSession.find(params[:insurance_session_id])
    @claim = InsuranceBilling.find(params[:insurance_billing_id])    
    #set the session variables     
    setup_session

    # create the secondary/tertiary/other claim
    @claim.transaction do
      @insurance_session.set_status_secondary(current_user.login_name)       
      @claim.update_attributes(:status => BillingFlow::CLOSED, :updated_user => current_user.login_name)
      #clone self
      @new_claim = InsuranceBilling.new(:status => BillingFlow::INITIATE, :insurance_session_id => @claim.insurance_session_id, 
                      :subscriber_id => @claim.subscriber_id, :insurance_billed => @claim.insurance_billed,
                      :created_user => current_user.login_name, :dos => @claim.dos, :patient_id => @claim.patient_id, 
                      :provider_id => @claim.provider_id, :group_id => @claim.group_id, :insurance_company_id => @claim.insurance_company_id )
      # save the new claim 
      if @new_claim.save
        # clone the procedure and idagnostic codes
        @new_claim.clone_iprocedures(@claim)
        @new_claim.clone_idiagnostics(@claim)
      end
      # reset the dollar amounts using the eob, if there is one.  Else keep the current rates
      # 8/7/13 - secondary charges should be the original charges.
      # calculate_secondary_charges(@session, @claim, @new_claim)
    end
    
    respond_to do |format|
      # go to the edit claim screen
      format.html {redirect_to insurance_session_insurance_billings_path(@insurance_session.id) }
    end
  end
  
  
  #
  # GET /waive/:insurance_billing_id
  # waive the remaining fee and close the claim & session
  def waive
    @insurance_session = InsuranceSession.find(params[:insurance_session_id])
    @claim = InsuranceBilling.find(params[:insurance_billing_id])
    claim_updated = false; session_updated = false
    
    @claim.transaction do 
      claim_updated = @claim.update_attributes(:status => BillingFlow::CLOSED, :updated_user => current_user.login_name) 
      puts @claim.errors.inspect if @claim.errors.any?
      session_updated = @insurance_session.update_attributes(:waived_fee => @insurance_session.balance_owed, :balance_owed => '0.0', :status => SessionFlow::CLOSED, :updated_user => current_user.login_name )
      puts @insurance_session.errors.inspect if @insurance_session.errors.any?
      puts "look at ins billing"
      @insurance_session.insurance_billings.each do |b|
        puts "#{b.id}, #{b.status}"
      end
    end
    
    respond_to do |format|
      if claim_updated && session_updated
        format.html { redirect_to eobs_path }
      else
        message = ""
        @claim.errors.full_messages.each {|msg| message += msg + ", "} if @claim.errors.any?
        @insurance_session.errors.full_messages.each {|msg| message += msg + ", "} if @insurance_session.errors.any?
        format.html { redirect_to eob_path(params[:eob_id]), notice: message }
      end
    end    
  end
  
  #
  # GET /balance/:insurance_billing_id
  # Need to close the current claim that is open and then goto new balance bill.
  def balance
    @insurance_session = InsuranceSession.find(params[:insurance_session_id])
    @claim = InsuranceBilling.find(params[:insurance_billing_id])
    #set the session variables
    setup_session

    respond_to do |format|
      if @claim.update_attributes(:status => BillingFlow::CLOSED, :updated_user => current_user.login_name)
        format.html { redirect_to new_insurance_session_balance_bill_session_path(params[:insurance_session_id]) }
      else
        message = ""
        @claim.errors.full_messages.each {|msg| message += msg + ", "} if @claim.errors.any?
        format.html { redirect_to insurance_session_insurance_billings_path(params[:insurance_session_id], params[:insurance_billing_id]),
                      notice: message}
      end
    end
  end
  
  private
  
  #
  # make sure the session variables are set correctly
  # insurance billings are to a patient, so the group, provider and patient info should be set in the session variables
  def setup_session
    #set the session variables 
    set_group_session(@insurance_session.group_id, @insurance_session.group.group_name) if !@insurance_session.group_id.blank?
    set_provider_session(@insurance_session.provider_id, @insurance_session.provider.provider_name)
    set_patient_session(@insurance_session.patient_id, @insurance_session.patient.patient_name)
    set_billing_session
    #set the return to path for using session notes
    session[:notes_return_to] = insurance_session_insurance_billings_path(@insurance_session.id)
  end


  def setup_diagnostic_variables(selection)
    case selection
    when "ICD9"
      @codes = CodesIcd9.all
      @var = "icd9_code"
    when "ICD10"
      #@codes = CodesIcd10.all
      #@var = "icd10_code"
    when "DSM"
      @codes = CodesDsm.dsm
      @var = "dsm_code"
    when "DSM4"
      @codes = CodesDsm.dsm4
      @var = "dsm4_code"
    else #default ot DSM5
      @codes = CodesDsm.dsm5
      @var = "dsm5_code"
    end
  end
  
  # clones the procedure nd diagnosis codes from the patient record  
  # need to pull the CPT and diags from the patient-group or patient-provider relationship
  def clone_procedure_diagnosis_codes(session, billing)
    @patient = Patient.find(session.patient_id) 
    
    # we keep going back and forth on how the rates apply.  sometimes we want the provider rates. other times we want the goup rates
    # initialliy changed due to kristin's group.  reverted back on 9/9 because rates would not match up.
    # different providers within the group can have different rates
    # need to use the provider rates for everything, unles the user chooses to not assign ratea to the provide and just to thte group
    jointable = (session.selector == Selector::GROUP) ? @patient.patients_groups.find_by_group_id(session.group_id) : @patient.patients_providers.find_by_provider_id(session.provider_id)
    #jointable = @patient.patients_providers.find_by_provider_id(session.provider_id)
    #if jointable.blank? && session.selector == Selector::GROUP
    #  jointable = @patient.patients_groups.find_by_group_id(session.group_id)
    #end
    billing.clone_iprocedures(jointable)
    billing.clone_idiagnostics(jointable)
  end
  

  def setup_rates_and_ein
    if @insurance_session.selector == Selector::GROUP      
      @rates = @insurance_session.group.rates
      @eins = [[@insurance_session.group.ein_number, @insurance_session.group.ein_number]]
    else
      @rates = @insurance_session.provider.rates
      @eins = []
      @eins.push [@insurance_session.provider.ein_number, @insurance_session.provider.ein_number] if !@insurance_session.provider.ein_number.blank? 
    end
  end
  

  def setup_codes
    #retreive the procedure codes
    @cpt_codes = CodesCpt.all
    @modifiers = CodesModifier.all    
    
    #retrive the diagnostic codes    
    #only grab the dsm codes.  Ajax will retrieve the other codes and display
    @codes = CodesDsm.all    
    @selection = "DSM"
  end
  
  
  def setup_base_variables
    @insurance_billings = @insurance_session.insurance_billings(:joins => :subscriber)
    @pos = CodesPos.find_by_code(@insurance_session.pos_code)  
    begin  # in case where there was a patient history record or a manage care record and then someone deleted it
      # if there is a patient injury record associated to the claim
      @patient_injury = @insurance_session.patient_injury
    rescue
      # if the variables exist, then leave there values, otherwise set them to nil
      @patient_injury ||= nil      
    end
    #list of patient insured records for dropdown
    @subscribers = Subscriber.find_all_by_patient_id(@insurance_session.patient_id, :include => :insurance_company)
    @select_options = @subscribers.collect {|u| ["#{u.ins_priority}, #{u.insurance_company_name}", u.id] }
    @managed_care = @insurance_session.patient.managed_cares    
  end
 
 
  # calculate the amount to bill secondary insurance
  # using current claim, loop through eobs, summing up each CPT code charged and paid
  # may have multiple eobs with payments - hence looping through
  # the balance due will be reset with the new calculated charges for insurance
  def calculate_secondary_charges(session, claim, new_claim)  
    # reset the balance due in session.
    # use the previous claim (claim) to calculate new values in new_claim
    # loop through all eobs to make sure we have a complete paid record for each line item
    charge = 0; payment = 0; sum = 0
    claim.eobs.each do |eob|
      # sum up all payments
      charge += eob.charge_amount
      payment += eob.payment_amount      
    end     # end of claim.eob loop  
    count = new_claim.iprocedures.count
    new_charge = charge - payment
    new_claim.iprocedures.each_with_index do |iproc, index| 
      #calculate the charge as a percentage
      if count == (index-1)
        # for the last cpt code, put the remainder of new_charge in the override
        iproc.rate_override = new_charge - sum      
      else
        # take a percentage of the new_charge 
        iproc.rate_override = (iproc.total_charge / charge) * new_charge
        sum += iproc.rate_override
      end
      iproc.total_charge = iproc.rate_override
    end   # end of new_claim.iprocedures loop
    new_claim.save!
  end
    
end
