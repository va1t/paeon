class InsuranceSessionsController < ApplicationController
  # user must be logged into the system
  before_filter :authenticate_user! 
  authorize_resource
  
  # GET /insurance_sessions
  # GET /insurance_sessions.json
  def index
    set_session_session
    
    if session[:patient]
      @insurance_sessions = InsuranceSession.find_all_by_patient_id(session[:patient], :order => ["dos DESC"])   
      @patient = Patient.find(session[:patient], :order => [:last_name, :first_name])
    else
      @insurance_sessions = []
      @patient = nil      
    end
    # for the group & Provider dropdowns
    @groups = Group.all(:order => :group_name)
    @providers = Provider.all(:order => [:last_name, :first_name])

    #set the default drop downs
    @group_selected = session[:group]
    @provider_selected = session[:provider]
    @patient_selected = session[:patient]
    if @group_selected
      @group = Group.find(@group_selected)
      @patients = @group.patients.order(:last_name, :first_name)
    elsif @provider_selected
      @provider = Provider.find(@provider_selected)
      @patients = @provider.patients.order(:last_name, :first_name)
    else
      @patients = []  
    end
    @title = "Patient Sessions"  
    @display_sidebar = true
    
    respond_to do |format|
      format.html # index.html.erb
      if session[:patient]
        format.json { render json: @insurance_sessions }
      else
        format.json { head :no_content }
      end
    end
  end
  
  # GET /insurance_sessions/:id
  # this is to redirect requests to the edit screen
  # this is primarilay triggered by the use of notes with the polymorphic relationship
  # the polymorhpic notes will return the user to the "show" for insurance session, although we can go to the same session notes from 
  # insurance billing and balance billing.  So we will look for the session[:return_to] and if it exists, redirect the user back to where the came from.
  # this keeps the notes logic simply and allows for granular control of the redirect.  both insurance_billing and balance_billing are nested routes under insurance_session.
  def show
    respond_to do |format|
      format.html { redirect_back_or_default edit_insurance_session_path(params[:id]) }  
    end    
  end

  # GET /insurance_sessions/new
  # GET /insurance_sessions/new.json
  def new
    # create a default session and billing record then take the user to the edit screen
    # this is to create the initial record in both tables so there is an ID and the procedure & diagnostic codes can be cloned / assigned 
    patient_id = params[:patient_id] ? params[:patient_id] : session[:patient]
    @patient = Patient.find(patient_id)
    @insurance_session = InsuranceSession.new(:status => SessionFlow::OPEN, :dos => (params[:dos] ? Date.strftime(params[:dos], "%m/%d/%Y") : Date.today),
                                              :copay_amount => 0.00, :patient_id => patient_id, :pos_code => @patient.pos_code)

    #set the group, Provider default id's and selection boxes
    set_group_and_provider_defaults       
    setup_patient_related_dropdowns(@patient)
    setup_group_and_provider_dropdowns(@patient)
    setup_rates_and_offices
    setup_other_codes    
    
    @display_sidebar = true
    @title = "New Session" 
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @insurance_session }
    end  
  end
  

  # GET /insurance_sessions/1
  # GET /insurance_sessions/1.json
  def edit
    set_session_session(params[:id])
    @insurance_session = InsuranceSession.find(params[:id])
    @notes = @insurance_session.notes    
    @patient = Patient.find(@insurance_session.patient_id)    
    setup_patient_related_dropdowns(@patient)
    setup_group_and_provider_dropdowns(@patient)
    setup_rates_and_offices
    setup_other_codes
    
    @show = true
    @display_sidebar = true
    @title = "Edit Session"    
  end


  # POST /insurance_sessions/1
  # POST /insurance_sessions/1.json
  def create
    @insurance_session = InsuranceSession.new(params[:insurance_session])        
    @insurance_session.created_user = current_user.login_name
            
    respond_to do |format|
      if @insurance_session.save              
        session[:dos] = @insurance_session.dos.strftime("%m/%d/%Y") 
        if params[:commit] == "Insurance Claim"
          format.html { redirect_to insurance_session_insurance_billings_path(@insurance_session), notice: 'Session was successfully updated.' }
        else
          format.html { redirect_to_balance_bill 'Session was successfully updated.' }
        end
        format.json { render json: @insurance_session }
      else
        format.html { 
          @patient = Patient.find(params[:insurance_session][:patient_id])
          setup_patient_related_dropdowns(@patient)
          setup_group_and_provider_dropdowns(@patient)
          setup_rates_and_offices
          setup_other_codes
          render action: "new" }
        format.json { render json: @insurance_session.errors, status: :unprocessable_entity }
      end
    end

  end


  # PUT /insurance_sessions/1
  # PUT /insurance_sessions/1.json
  def update
    @insurance_session = InsuranceSession.includes(:balance_bill_session).find(params[:id])
    @insurance_session.updated_user = current_user.login_name    
    
    respond_to do |format|
      if @insurance_session.update_attributes(params[:insurance_session])
        # set session for cloning session / billing records for the next patient
        session[:dos] = @insurance_session.dos.strftime("%m/%d/%Y")
        logger.info "Saved the record"
        if params[:commit] == "Insurance Claim"
          format.html { redirect_to insurance_session_insurance_billings_path(@insurance_session), notice: 'Session was successfully updated.' }
        else
          format.html { redirect_to_balance_bill 'Session was successfully updated.' }
        end
        format.json { render json: @insurance_session }
      else
        logger.info "Did not save the record"
        format.html { 
          @patient = Patient.find(params[:insurance_session][:patient_id])
          setup_patient_related_dropdowns(@patient)
          setup_group_and_provider_dropdowns(@patient)
          setup_rates_and_offices
          setup_other_codes
          render action: "edit" }
        format.json { render json: @insurance_session.errors, status: :unprocessable_entity }
      end
    end
  end


  # DELETE /insurance_sessions/1
  # DELETE /insurance_sessions/1.json
  def destroy
    @insurance_session = InsuranceSession.find(params[:id])
    @insurance_session.update_column(:updated_user, current_user.login_name)
    @insurance_session.destroy

    respond_to do |format|
        format.html { redirect_to insurance_sessions_url }
        format.json { head :no_content }
    end
  end
  
    
  # in the index page when a group or Provider selection is changed, this function is triggered by ajax 
  def ajax_group
    @group_selected = params[:group_id]
    @provider_selected = params[:provider_id]
    @patient_selected = nil
    @patients = []
    @patient = nil
    
    @groups = Group.all(:order => :group_name)
    if !@group_selected.blank?
      @group = Group.find(@group_selected)
      @providers = @group.providers(:order => [:last_name, :first_name])   
      @patients = @group.patients.order(:last_name, :first_name)
      set_group_session @group.id, @group.group_name
     
      if !@provider_selected.blank?
        @provider = Provider.find(@provider_selected)
        set_provider_session @provider.id, @provider.provider_name
      end
    elsif !@provider_selected.blank?
      #group is nil, but Provider is not, blank out the groupn 
      session[:group] = nil
      session[:group_name] = nil

      @providers = Provider.all(:order => [:last_name, :first_name])
      @provider = Provider.find(@provider_selected)      
      @patients = @provider.patients.order(:last_name, :first_name)
      set_provider_session @provider.id, @provider.provider_name
      # if context == Billing, override it to be Provider
      if session[:context] == BILLING
        session[:context] = PROVIDER
      end
    else
      #both group and Provider are blank, so make sure the sessions are cleared and reset to default billing
      session_reset
      set_billing_session
      @providers = Provider.all(:order => [:last_name, :first_name])
    end

    respond_to do |format|
      format.html {render :nothing => true}
      format.js {render :layout => false }                   
    end
  end


  # in the index age when the patient select field is changed, this function is triggered by ajax
  # the index_table is updated with the selected user's info
  # also the sidebar is updated for the new session link to include the group and Provider currently selected as additional parameters
  def ajax_patient
    if !params[:patient_id].blank?
      @patient_selected = params[:patient_id]
      @insurance_sessions = InsuranceSession.find_all_by_patient_id(params[:patient_id], :order => ["dos DESC"]) 
      @patient = Patient.find(params[:patient_id])
      #seting the patient name by ajax.  Only called when :insbilling is true and dropdown are displayed
      set_patient_session @patient.id, @patient.patient_name 
    else
      @insurance_sessions = []
      @patient = nil
      @patient_selected = nil    
    end
    
    respond_to do |format|
      format.html {render :nothing => true}
      format.js {render :layout => false }      
    end  
  end
 
 
  def ajax_reset
    reset_session
    redirect_to insurance_sessions_path
  end


  private
     
  
  def setup_patient_related_dropdowns(patient)    
    @subscriber = patient.subscribers.find(:all, :joins => [:insurance_company])
    # needed to build the array for the subscriber select tag because some of the data was through the has_many associations
    @select_options = @subscriber.collect {|u| ["#{u.ins_priority}, #{u.insurance_company.name}", u.id] }      
    @patient_injury = patient.patient_injuries    
  end
  
  # set the dropdown boxes for selecitng the group and provider
  def setup_group_and_provider_dropdowns(patient)
    if !patient.blank?
      # by default display all the groups and providers associated to the patient      
      @groups = patient.groups
      @providers = patient.providers
    else
      # set parameters to null,  on the page "no assoc" text will display
      @groups = []
      @providers = []      
    end
  end
  

  def setup_rates_and_offices
    @account = nil
    @rates = []
    @office = []

    if @insurance_session[:selector] == Selector::PROVIDER #if Provider is selected
      if !@insurance_session[:provider_id].blank?
        @provider = Provider.find(@insurance_session[:provider_id])
        @rates = @provider.rates
        @office = @provider.offices         
        billing_office = @provider.offices.find_by_billing_location(true)
        @insurance_session.billing_office_id ||= billing_office.id if billing_office
        service_location = @provider.offices.find_by_service_location(true)
        @insurance_session.office_id ||= service_location.id if service_location
        temp = @patient.patients_providers.where(:provider_id => @insurance_session[:provider_id]).first
        @account = temp.patient_account_number
        @special_rate = temp.special_rate
      end
    elsif @insurance_session[:selector] == Selector::GROUP #if group is selected
      if !@insurance_session[:group_id].blank?
        temp = @patient.patients_groups.where(:group_id => @insurance_session[:group_id]).first
        @account = temp.patient_account_number    
        @special_rate = temp.special_rate
        @group = Group.find(@insurance_session[:group_id])              
        @rates = @group.rates
        @office = @group.offices
        billing_office = @group.offices.find_by_billing_location(true)
        @insurance_session.billing_office_id ||= billing_office.id if billing_office
        service_location = @group.offices.find_by_service_location(true)
        @insurance_session.office_id ||= service_location.id if service_location  
      end
    end    
  end

  def setup_other_codes        
    #place of service codes
    @pos_codes = CodesPos.all
    
    #retreive the procedure codes    
    @cpt_codes = CodesCpt.all
    @modifiers = CodesModifier.all    
    
    #retrive the diagnostic codes    
    #only grab the dsm codes.  Ajax will retrieve the other codes and display
    @codes = CodesDsm.all    
    @selection = "DSM"
  end

  def set_group_and_provider_defaults    
    # the next 2 if statements handle if the user is coming in through with context set to Group, Provider or Billing
    if !session[:group].blank?
      #either came through the group->Provider->patient flow or selected group from dropdowns
      @insurance_session.selector = Selector::GROUP
      @insurance_session.group_id = session[:group]
      if session[:provider].blank?
        @group = Group.find(session[:group])
        @insurance_session.provider_id = @group.providers.first.id
      end
    end
           
    if !session[:provider].blank? 
      #either came through the Provider->patient flow or selected Provider from the dropwdowns
      @insurance_session.provider_id = session[:provider]      
      #didnt set the selection via group, so set it for Provider
      @insurance_session.selector = Selector::PROVIDER if @insurance_session.selector.blank?
    end

    # if context is set to Patient, then we have to handle separately to determine a default Provider to initialize the record
    if session[:context] == PATIENT
      #came through the patient flow so session variables are not set for group or Provider            
      @provider = @patient.providers.first
      @group = @patient.groups.first
      if @provider
        #default to the first Provider set on the patient record
        @insurance_session.selector = Selector::PROVIDER
        @insurance_session.provider_id = @provider.id              
      elsif @group
        #if no Provider, default to the first group, first Provider of group
        @insurance_session.selector = Selector::GROUP
        @insurance_session.group_id = @group.id
        @insurance_session.provider_id = @group.providers.first.id
      else
        # no groups or no Providers, then we cant have an insurance billing and need to return an error page.
        @message = "The selected patient, #{@patient.patient_name} does not have an associated Group or Providers.  Therefore the patient cannot have a session / claim record. "
        @message += "To resolve this error, please associate the selected patient to at least one Provider."
      end
    end
  end
  
  
  def redirect_to_balance_bill(notice = nil)
    if @insurance_session.balance_bill_session && @insurance_session.balance_bill_session.count > 0 
      redirect_to edit_insurance_session_balance_bills_path(@insurance_session, @insurance_session.balance_bill_session.id), notice: notice
    else
      redirect_to new_insurance_session_balance_bill_session_path(@insurance_session), notice: notice
    end
    
  end
  
end


