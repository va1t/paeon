class EobsController < ApplicationController
  layout "processing"
  # user must be logged into the system
  before_filter :authenticate_user!
  authorize_resource

  # GET /eobs
  # GET /eobs.json
  def index
    @eobs = Eob.assigned
    @title = "Posted EOBs"

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @eobs }
    end
  end

  # GET /eob/1
  # GET /eob/1/json
  def show
    @eob = Eob.find(params[:id])
    # if the eob is assigned, bring up the claim details in the right sidebar
    @display_sidebar = true
    if !@eob.insurance_billing_id.blank?
      @patient = Patient.find(@eob.patient_id)
      @claim = @eob.insurance_billing(:joins => [:insurance_session, :subscriber])
      @office = @claim.insurance_session.office
      @claim_office = @claim.insurance_session.billing_office
    else
      # tell the right sidebar to pull data for unassigned eob
      @pull_from_eob = true
    end
    session[:return_to] = eobs_path

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @eobs }
    end
  end


  #
  # GET /eobs/1/showeob.pdf
  # Creates the pdf version of the eob for printing
  def showeob
    @eob = EobReport.new(params[:id])
    @eob.build
    respond_to do |format|
      format.pdf { send_data @eob.render, :filename => "eob.pdf", :type => "application/pdf" }
    end
  end


  # GET /eobs_unassigned
  # GET /eobs_unassigned.json
  def unassigned
    @eobs = Eob.unassigned
    puts @eob.inspect
    @title = "Unassigned EOB's"
    @subtitle = "Link the EOB to an open claim"

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @eobs }
    end
  end


  # GET /eobs/new
  # GET /eobs/new.json
  # enters the header information to create the initial record so eob_details can be associated to it.
  def new
    @eob = Eob.new
    if params[:patient_id]
      @patient = Patient.find(params[:patient_id])
      @claim = InsuranceBilling.find(params[:claim], :joins => [:insurance_session, :subscriber])
      @eob.patient_id = @patient.id
      @eob.insurance_billing_id = @claim.id
      @eob.dos = @claim.dos
      fillin_fields_for_manual_eob
    else
      # get a list of patients with open claim
      @claims_outstanding = InsuranceBilling.processed
      # collect the patient, sort them and remove the duplicates
      temp_patients = @claims_outstanding.collect {|c| [c.patient.patient_name, c.patient.id]}.sort
      @patients = []
      cur_patient = ""
      temp_patients.each do |tc|
        if cur_patient != tc[0]
          @patients.push tc
          cur_patient = tc[0]
        end
      end
    end
    @payment_method = Eob::PAYMENT_METHOD
    @display_sidebar = true
    @title = "Enter a New EOB"

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @eob }
    end
  end


  # GET /eobs/1/edit
  # allows the modification of the eob information and eob_detail inforomation
  def edit
    @eob = Eob.find(params[:id])
    @patient = Patient.find(@eob.patient_id)
    @claim = @eob.insurance_billing(:joins => [:insurance_session, :subscriber])
    @payment_method = Eob::PAYMENT_METHOD
    @display_sidebar = true
    @title = "Edit EOB and EOB Detail"
    @notes = @claim.insurance_session.notes

    session[:return_to] = request.original_url

    respond_to do |format|
      format.html # edit.html.erb
      format.json { render json: @eob }
    end
  end


  # GET /eob_unassigned/1/edit
  # allows the modification of the eob information and eob_detail inforomation
  def unassigned_edit
    @eob = Eob.find(params[:id])
    # get all the open claims for populating the selects & displaying claims
    # initially display all open claims, allow selects to narrow the field
    @claims = InsuranceBilling.processed
    # create the array for the selects
    @patients = @claims.collect {|c| [c.insurance_session.patient.patient_name, c.insurance_session.patient_id]}.uniq.sort
    @providers = @claims.collect {|c| [c.insurance_session.provider.provider_name, c.insurance_session.provider.id]}.uniq.sort
    @groups = @claims.collect {|c| [c.insurance_session.group.group_name, c.insurance_session.group.id] if c.insurance_session.group }.uniq
    @payees = @claims.collect {|c| [c.subscriber.insurance_company.name, c.subscriber.insurance_company.id]}.uniq.sort
    @title = "Edit Unassigned EOB"

    respond_to do |format|
      format.html # edit.html.erb
      format.json { render json: @eob }
    end
  end


  # POST /eobs
  # POST /eobs.json
  def create
    @eob = Eob.new(params[:eob])
    @claim = InsuranceBilling.find(@eob.insurance_billing_id)
    @patient = Patient.find(@claim.patient_id)
    @eob.created_user = current_user.login_name

    #set eob manually entered to true
    @eob.manual = true
    fillin_fields_for_manual_eob
    @payment_method = Eob::PAYMENT_METHOD

    respond_to do |format|
      if @eob.save
        format.html { redirect_to edit_eob_path(@eob), notice: 'EOB was successfully saved.' }
        format.json { render json: @eob, status: :created, location: @eob }
      else
        format.html {
          @patients = Array.new [@patient.patient_name, @patient.id]
          render action: "new" }
        format.json { render json: @eob.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /eobs/1
  # PUT /eobs/1.json
  def update
    @eob = Eob.find(params[:id])
    # make sure the insurance billing id field is set
    @eob.insurance_billing_id ||= params[:eob][:insurance_billing_id] if !params[:eob][:insurance_billing_id].blank?
    @claim = InsuranceBilling.find(@eob.insurance_billing_id)
    @patient = Patient.find(@claim.patient_id)
    @eob.updated_user = current_user.login_name
    #make sure all the *_id fields are current
    fillin_fields_for_manual_eob
    @payment_method = Eob::PAYMENT_METHOD

    if params[:eob]
      @eob_details = params[:eob][:eob_details_attributes]
      if @eob_details
        @eob_details.each do |x, e|
          e[:dos] = @eob.dos
          e[:provider_id] = @eob.provider_id
          e[:created_user] = current_user.login_name if e[:created_user].blank?
          e[:updated_user] = current_user.login_name
        end
      end
    end

    respond_to do |format|
      if @eob.update_attributes(params[:eob])
        format.html { redirect_to eob_path(@eob), notice: 'EOB was successfully updated.' }
        format.js { redirect_to edit_eob_path(@eob), notice: 'Detail Added' }
        format.json { head :no_content }
      else
        format.html { redirect_to edit_eob_path(@eob), notice: 'Error updating EOB' }
        format.js { render action: "edit" }
        format.json { render json: @eob.errors, status: :unprocessable_entity }
      end
    end
  end


  # DELETE /eobs/1
  # DELETE /eobs/1.json
  def destroy
    @eob = Eob.find(params[:id])
    @eob.updated_user = current_user.login_name
    @eob.destroy

    respond_to do |format|
      format.html {
        # if the referer is nill then send the user to the home page
        if request.referer.blank?
          redirect_to home_index_path
        else
          redirect_to request.referer
        end
      }
      format.json { head :no_content }
    end
  end


  # GET /eobs/ajax_patient
  # Updates the open claim select box when a patient is selected
  # patient_id is passed in the parameter list
  def ajax_patient
    patient_id = params[:eob][:patient_id]
    # get a list of patients with open claim
    @patient = Patient.find(patient_id)
    @claims_outstanding = InsuranceBilling.processed.where("insurance_billings.patient_id = ?", patient_id)

    respond_to do |format|
      format.html {render :nothing => true}
      format.js {render :layout => false }
    end
  end


  # GET /eob/ajax_claim
  # updates the subscriber an submitted claim box; makes the eob visible
  #
  def ajax_claim
    billing_id = params[:eob][:insurance_billing_id]
    # pull the specific claim
    @claim = InsuranceBilling.find(billing_id, :joins => [:insurance_session, :subscriber])
    @notes = @claim.insurance_session.notes

    respond_to do |format|
      format.html {render :nothing => true}
      format.js {render :layout => false }
    end
  end

  # GET /eob/:id/ajax_detail
  # adds another detail record for the eob
  #
  def ajax_detail
    @eob = Eob.find(params[:id])
    @eob_details = []
    if params[:eob]
      @attributes = params[:eob][:eob_details_attributes]
      @attributes.each do |key, value|
        @eob_details.push @eob.eob_details.build(value)
      end
    end
    @count = @eob.eob_details.count
    @eob_details.push @eob.eob_details.build()

    respond_to do |format|
      format.js {render :layout => false }
    end
  end

  # GET /eob/ajax_unassigned
  # Updates the selected open claims when a drop down box is updated
  #
  def ajax_unassigned
    if params[:patient_id] && !params[:patient_id].blank?
      @claims = InsuranceBilling.processed.where("insurance_billings.patient_id = ?", params[:patient_id])
    elsif params[:provider_id] && !params[:provider_id].blank?
      @claims = InsuranceBilling.processed.where("insurance_billings.provider_id = ?", params[:provider_id])
    elsif params[:group_id] && !params[:group_id].blank?
      @claims = InsuranceBilling.processed.where("insurance_billings.group_id = ?", params[:group_id])
    elsif params[:payee_id] && !params[:payee_id].blank?
      @claims = InsuranceBilling.processed.where("insurance_billings.insurance_company_id = ?", params[:payee_id])
    else
      # no parameters passed, reset to all open claims
      @claims = InsuranceBilling.processed
    end

    respond_to do |format|
      format.js {render :layout => false }
    end
  end

  private

  def fillin_fields_for_manual_eob
    #set the provider and group ids - allow for easier retreival of data
    @eob.provider_id = @claim.provider_id
    @eob.group_id = @claim.group_id
    @eob.subscriber_id = @claim.subscriber_id
    #set claim information
    @eob.claim_number = @claim.claim_number
    @eob.claim_date = @claim.claim_submitted
    @eob.service_start_date = @claim.dos
    @eob.service_end_date = @claim.dos
    #set subscriber info
    @eob.subscriber_first_name = @claim.subscriber.subscriber_first_name
    @eob.subscriber_last_name = @claim.subscriber.subscriber_last_name
    @eob.subscriber_ins_policy = @claim.subscriber.ins_policy
    @eob.group_number = @claim.subscriber.ins_group
    # set insurance company info
    @eob.insurance_company_id = @claim.subscriber.insurance_company_id
    @eob.payor_name ||= @claim.subscriber.insurance_company.name
    #set patient info
    @eob.patient_first_name = @patient.first_name
    @eob.patient_last_name = @patient.last_name
    #set provider
    @eob.provider_first_name = @claim.provider.first_name
    @eob.provider_last_name = @claim.provider.last_name
    @eob.provider_npi = @claim.provider.npi

    #set payee information; based on the selected in session
    if @claim.insurance_session.selector == Selector::GROUP
      #group was selected under session for claim processing
      @eob.payee_name = @claim.group.group_name
      @eob.payee_npi = @claim.group.npi
      @eob.payee_ein = @claim.group.ein_number
      @payor = @claim.group.provider_insurances.find_by_insurance_company_id(@claim.insurance_company_id)
    else
      @eob.payee_name = @claim.provider.provider_name
      @eob.payee_npi = @claim.provider.npi
      @payor = @claim.provider.provider_insurances.find_by_insurance_company_id(@claim.insurance_company_id)
      @eob.payee_ein = @claim.provider.ein_number
      @eob.payee_ssn = @claim.provider.ssn_number
    end
    @eob.payee_payor_id = @payor.provider_id if !@payor.blank?
    @office = @claim.insurance_session.office
    @eob.payee_address1 = @office.address1
    @eob.payee_address2 = @office.address2
    @eob.payee_city = @office.city
    @eob.payee_state = @office.state
    @eob.payee_zip = @office.zip

    case @claim.secondary_status
    when SessionFlow::PRIMARY
      @eob.claim_status_code = 1
    when SessionFlow::SECONDARY
      @eob.claim_status_code = 2
    else
      @eob.claim_status_code = 3
    end
  end

end
