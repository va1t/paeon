class ProcessingController < ApplicationController
  # user must be logged into the system
  before_filter :authenticate_user!  
  
  # display claims ready to be processed, allow user to select claims to process
  # the post will route to submit
  # GET /processing/claim_ready  
  def claim_ready
    authorize! :manage, :processing
    reset_session
    @edi_claims = InsuranceBilling.pending 
    @title = "Claims Ready for Submission"
 
    respond_to do |format|
      format.html # claim_ready.html.erb
      format.json { render json: @edi_claims }
    end
  end
  
  #
  # In the processing controllers, all session varaibles are cleared on the users browser.
  # when selecting to view a claim, the session variables need to be set
  # this method sets the session variables and then redirects the browser to the insurance_billing#index page
  # GET /processing/claim_ready_session/:id
  def claim_ready_session
    authorize! :manage, :processing
    reset_session
    @insurance_billing = InsuranceBilling.find(params[:id])
    
    if !@insurance_billing.group_id.blank?
      set_group_session(@insurance_billing.group_id, @insurance_billing.group.group_name)
    end
    set_provider_session(@insurance_billing.provider_id, @insurance_billing.provider.provider_name)
    set_patient_session(@insurance_billing.patient_id, @insurance_billing.patient.patient_name)
    
    respond_to do |format|
      format.html { redirect_to insurance_session_insurance_billings_path(@insurance_billing.insurance_session_id) }
      format.json { head :no_content }
    end
  end
  
  # process the claims selected for submission,  build the edi transaction and send to clearinghouse
  # reply with a screen confirming claims sent with the control numbers
  # POST /submit
  def claim_submit
    authorize! :manage, :processing
    reset_session
    @title = "Submission Results"
    #check for edi vendor      
    @edivendor = EdiVendor.primary.first      
    respond_to do |format|
      if params[:commit] == "View Claims" && params[:checked]
        @title = "View Submission Results"
        # print the claims selected
        @hcfa = HcfaForm.new(params[:checked])
        @hcfa.build
        format.pdf { send_data @hcfa.render, :filename => "hcfa.pdf", :type => "application/pdf" }
        format.html { send_data @hcfa.render, :filename => "hcfa.pdf", :type => "application/pdf" }
      elsif (params[:commit] == "Print Claims" || params[:commit] == "Download PDF") && params[:checked]
        @title = "Print Submission Results"
        # print the claims selected, send false to not use the form
        @hcfa = HcfaForm.new(params[:checked], false)
        @hcfa.build
        format.pdf { send_data @hcfa.render, :filename => "hcfa.pdf", :type => "application/pdf" }
        format.html { send_data @hcfa.render, :filename => "hcfa.pdf", :type => "application/pdf" }    
        #update insurance_billing   
        params[:checked].each { |c| InsuranceBilling.update(c, {:status => BillingFlow::PRINTED, :claim_submitted => DateTime.now, :updated_user => current_user.login_name}) }   
      end
    end 
  end
    
  
  #display the claims processed, received a 999 but not recieved an eob
  # GET /claim_submitted
  def claim_submitted
    authorize! :manage, :processing
    reset_session
    # for multiple clearing houses will need to chnage the query to pull only the procesed claim for the selected vendor
    # for right now will pull all processed claims because they are going to office ally
    if params[:aged]
      @days = params[:aged].to_i
      @claims_submitted = InsuranceBilling.aged_processed(@days.days.ago)
    else
      @claims_submitted = InsuranceBilling.processed
    end
    
    @title = "Claims Submitted"
    respond_to do |format|
      format.html # claim_submitted.html.erb
      format.json { render json: @claims_submitted }
    end    
  end
  
  
  #
  # GET /resubmit
  # closes the current claim.  creates a new claim and clones the closed claims information
  def claim_resubmit
    authorize! :manage, :processing
    reset_session
    # close the claim
    @claim = InsuranceBilling.find(params[:id])
    respond_to do |format|
      if @claim.update_attributes(:status => BillingFlow::CLOSED_RESUBMIT, :updated_user => current_user.login_name)
        # create new claim / cloning data
        @new_claim = InsuranceBilling.new(:status => BillingFlow::INITIATE, :insurance_session_id => @claim.insurance_session_id, 
                      :subscriber_id => @claim.subscriber_id, :insurance_billed => @claim.insurance_billed,
                      :created_user => current_user.login_name, :dos => @claim.dos, :patient_id => @claim.patient_id, 
                      :provider_id => @claim.provider_id, :group_id => @claim.group_id, :insurance_company_id => @claim.insurance_company_id )
        # save the new claim 
        if @new_claim.save
          #clone the procedure and idagnostic codes
          @new_claim.clone_iprocedures(@claim)
          @new_claim.clone_idiagnostics(@claim)
        end      
        #set the session variables 
        set_group_session(@new_claim.group_id, @new_claim.group.group_name) if !@new_claim.group_id.blank?
        set_provider_session(@new_claim.provider_id, @new_claim.provider.provider_name)
        set_patient_session(@new_claim.patient_id, @new_claim.patient.patient_name)
        format.html {redirect_to insurance_session_insurance_billings_path(@new_claim.insurance_session_id)}
      else
        format.html {redirect_to processing_claim_view_path(@claim.id)}
      end
    end    
  end
  
  
  #display all sessions that have processed and received eobs.
  def session_history
    authorize! :manage, :processing
    reset_session
    @edi_claims = InsuranceBilling.completed
    @title = "Completed / Closed Claims"

    respond_to do |format|
      format.html # history.html.erb
      format.json { render json: @edi_claims }
    end
  end
  
  
  # GET /processing/print_claim
  # landing page for printing claims. the routine for creating pdf's can return only the pdf and no update the page.
  # this landing page cleans up the user expereince so when they return to the claims ready page, the printed claims are gone.  
  # displays the claims selected for printing and calls the routine to create the printed pdf.  
  def print_claim
    authorize! :manage, :processing
    reset_session
    @claims = params[:checked]    
    @title = "Creating the PDF for Printing Claims"    
    @selected = []
    @claims.each { |c| @selected.push InsuranceBilling.find(c) }    
  end
  
  
  # GET processing/print_balance
  # landing page for the printing of balance bills. the routine for printing balance bills can return only one action, such as the pdf file
  # this landing page cleans up the user experience so when they download the pdf, the underlying html page is not the 'ready for submission'
  # page still showing the blaance bills printed.
  def print_balance
    authorize! :manage, :processing
    reset_session
    @balance_bills = params[:checked]
    @title = "Creating the PDF for Printing Balance Bills"
    @selected = []
    @balance_bills.each { |b| @selected.push BalanceBill.find(b) }
  end
  
  
  #
  #
  # GET /view_advice
  def view_advice
    authorize! :manage, :processing
    reset_session
    #TODO: gets updated for multiple vendors
    redirect_to office_ally_display_files_index_path
  end

end
