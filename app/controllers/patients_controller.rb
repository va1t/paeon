class PatientsController < ApplicationController
  # user must be logged into the system
  before_filter :authenticate_user!
  authorize_resource

  # GET /patients
  # GET /patients.json
  def index
    #@patients = Patient.find(:all, :order => 'last_name ASC, first_name ASC').paginate(:page => params[:page], :per_page => 30)
    @patients = Patient.page(params[:page]).order('last_name ASC, first_name ASC')
    set_patient_session
    @title = "Patient Listing"

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @patients }
    end
  end


  # GET /patients/1
  # GET /patients/1.json
  def show
    @patient = Patient.find(params[:id])

    @subscriber = @patient.subscribers
    @managed_care = @patient.managed_cares
    set_patient_session @patient.id, @patient.patient_name
    @patient_pos = @patient.pos_code ? CodesPos.find_by_code(@patient.pos_code) : nil

    # @groups and @providers are plural here in the show action
    @groups = @patient.groups
    @providers = @patient.providers
    @subscribers = @patient.subscribers.find(:all, :joins => [:insurance_company], :include => :subscriber_valids, :order => "ins_priority")

    #retreive the procedure codes
    @cpt_codes = CodesCpt.without_status :deleted, :archived
    @modifiers = CodesModifier.without_status :deleted, :archived
    #only grab the dsm codes.  Ajax will retrieve the other codes and display
    @dsm_codes = CodesDsm.without_status :deleted, :archived

    # set the cpt & diags to display the first the Provider.
    # if no Provider assoc exists, then display first group
    if select_primary_codes_for_display
      #retrive the diagnostic codes
      @diag_code = @primary.idiagnostics
      @validated = build_validated_subscriber_list(@subscribers)
    end

    #set the return_to session parameter for when saving procedure codes
    session[:return_to] = patient_path(@patient)

    @history = PatientInjury.where(:patient_id => params[:id])
    @title = "Show Patient Information"
    @show = true
    @display_sidebar = true
    @session = @patient.insurance_sessions.includes(:provider).where("insurance_sessions.status < ?", SessionFlow::CLOSED)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @patient }
    end
  end


  # GET /patients/new
  # GET /patients/new.json
  def new
    reset_session
    setup_static_variables
    # if the patient_id param is passed, then duplicate that patient in the new record
    # duplicate everything except for first name, ssn and dob
    if params[:patient_id]
      @patient = Patient.find(params[:patient_id]).dup
      @patient.first_name = ""
      @patient.dob = ""
      @patient.ssn_number = ""
    else
      @patient = Patient.new
    end
    set_patient_session
    @title = "New Patient"
    @new_patient = true


    #place of service codes
    @patient.pos_code = CodesPos.where(:code => '11').first.code  #default to code 11, office
    @pos_codes = CodesPos.without_status :deleted, :archived

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @patient }
    end
  end


  # POST /patients
  # POST /patients.json
  def create
    @patient = Patient.new(params[:patient])
    @patient.created_user = current_user.login_name
    set_patient_session @patient.id, @patient.patient_name

    respond_to do |format|
      if @patient.save
        format.html { redirect_to patient_path(@patient), notice: 'Patient was successfully created.' }
        format.json { render json: @patient, status: :created, location: @patient }
      else
        format.html {
          setup_static_variables
          render action: "new" }
        format.json { render json: @patient.errors, status: :unprocessable_entity }
      end
    end
  end


  # GET /patients/1/edit
  def edit
    setup_static_variables
    @patient = Patient.find(params[:id])
    set_patient_session @patient.id, @patient.patient_name
    @title = "Edit Patient"
    @show_patient = true
  end


  # PUT /patients/1
  # PUT /patients/1.json
  def update
    @patient = Patient.find(params[:id])
    @patient.updated_user = current_user.login_name
    set_patient_session @patient.id, @patient.patient_name

    respond_to do |format|
      if @patient.update_attributes(params[:patient])
        format.html { redirect_back_or_default patient_path(@patient), notice: 'Patient was successfully created.' }
        format.json { head :no_content }
      else
        format.html {
          setup_static_variables
          render action: "edit"
        }
        format.json { render json: @patient.errors, status: :unprocessable_entity }
      end
    end
  end


  # DELETE /patients/1
  # DELETE /patients/1.json
  def destroy
    @patient = Patient.find(params[:id])
    @patient.destroy
    set_patient_session

    respond_to do |format|
      format.html { redirect_to patients_path }
      format.json { head :no_content }
    end
  end


  # GET /patients/:id/group_associate
  def group_associate
    @patient = Patient.find(params[:id])
    @groups = Group.find(:all, :include => :patients_groups, :order => :group_name)
    set_patient_session @patient.id, @patient.patient_name
    @title = "Associate Patients to Groups"
    session[:return_to] = patients_groups_patients_path(params[:id])
    session[:on_error] = "group_associate"
    @show_patient = true
  end


  # GET /patients/:id/provider_associate
  def provider_associate
    @patient = Patient.find(params[:id])
    @providers = Provider.find(:all, :include => :patients_providers, :order =>[:last_name, :first_name] )

    set_patient_session @patient.id, @patient.patient_name
    @title = "Associate Patients to Providers"
    session[:return_to] = patients_providers_patients_path(params[:id])
    session[:on_error] = "provider_associate"
    @show_patient = true
  end


  # PUT /patients/:id/update_associate
  # PUT /patients/:id/update_associate.json
  def update_associate
    @patient = Patient.find(params[:id])
    @patient.updated_user = current_user.login_name
    set_patient_session @patient.id, @patient.patient_name

    respond_to do |format|
      if @patient.update_attributes(params[:patient])
        format.html { redirect_back_or_default patient_path(@patient), notice: 'Patient Associations were successfully updated.'}
        format.json { head :no_content }
      else
        format.html { render action: session[:on_error] }
        format.json { render json: @patient.errors, status: :unprocessable_entity }
      end
    end
  end

  # Get /patients/ajax_diagnosis
  # updates the diagnostics drop down box when slecting different radio buttons
  def ajax_diagnosis
    @diag = params[:idiagnostic]
    case @diag[:selection]
    when "ICD9"
      @codes = CodesIcd9.without_status :deleted, :archived
      @var = "icd9_code"
    when "ICD10"
      #@codes = CodesIcd10.without_status :deleted, :archived
      #@var = "icd10_code"
    when "DSM"
      @codes = CodesDsm.dsm.without_status :deleted, :archived
      @var = "dsm_code"
    when "DSM4"
      @codes = CodesDsm.dsm4.without_status :deleted, :archived
      @var = "dsm4_code"
    else #default ot DSM5
      @codes = CodesDsm.dsm5.without_status :deleted, :archived
      @var = "dsm5_code"
    end

    respond_to do |format|
      format.js {render :layout => false }
    end
  end

  # Get /patients_groups/ajax_procedure
  # retreives the current set of iprocedures for the patient
  # builds a new record onto the set
  def patients_groups_ajax_procedure
    @patient = Patient.find(params[:patient_id])
    @primary = @patient.patients_groups.find_by_group_id(params[:group_id])
    @primary.iprocedures.build(:created_user => current_user.login_name)
    @primary_selection = Selector::GROUP
    #retreive the procedure codes
    @cpt_codes = CodesCpt.without_status :deleted, :archived
    @modifiers = CodesModifier.without_status :deleted, :archived
    @rates = @patient.groups.find(params[:group_id]).rates
    @mod_cpt_save = {:group_id => params[:group_id]}
    session[:return_to] = patient_path(@patient)

    respond_to do |format|
      format.js {render :layout => false }
    end
  end

  # Get /patients_providers/ajax_procedure
  # retreives the current set of iprocedures for the patient
  # builds a new record onto the set
  def patients_providers_ajax_procedure
    @patient = Patient.find(params[:patient_id])
    @primary = @patient.patients_providers.find_by_provider_id(params[:provider_id])
    @primary.iprocedures.build(:created_user => current_user.login_name)
    @primary_selection = Selector::PROVIDER
    #retreive the procedure codes
    @cpt_codes = CodesCpt.without_status :deleted, :archived
    @modifiers = CodesModifier.without_status :deleted, :archived
    @rates = @patient.providers.find(params[:provider_id]).rates
    @mod_cpt_save = {:provider_id => params[:provider_id]}
    session[:return_to] = patient_path(@patient)

    respond_to do |format|
      format.js {render :layout => false }
    end
  end

  # called when a Provider or group link is clicked to redraw the diag / cpt fields
  def ajax_redraw
    @patient = Patient.find(params[:patient_id])
    @groups = @patient.groups
    @providers = @patient.providers

    if params[:group_id]
      @primary = @patient.patients_groups.find_by_group_id(params[:group_id])
      @primary_selection = Selector::GROUP
      @group = @patient.groups.find(params[:group_id])
      @primary_name = @group.group_name
      @rates = @group.rates
      @mod_cpt_save = {:group_id => params[:group_id]}
    elsif params[:provider_id]
      @primary = @patient.patients_providers.find_by_provider_id(params[:provider_id])
      @primary_selection = Selector::PROVIDER
      @provider = @patient.providers.find(params[:provider_id])
      @primary_name = @provider.provider_name
      @rates = @provider.rates
      @mod_cpt_save = {:provider_id => params[:provider_id]}
    else
      @primary = nil
    end
    session[:return_to] = patient_path(@patient)

    @diag_code = @primary.idiagnostics
    @cpt_codes = CodesCpt.without_status :deleted, :archived
    @modifiers = CodesModifier.without_status :deleted, :archived
    #only grab the dsm codes.  Ajax will retrieve the other codes and display
    @dsm_codes = CodesDsm.without_status :deleted, :archived

    @subscribers = @patient.subscribers.find(:all, :joins => [:insurance_company], :include => :subscriber_valids, :order => "ins_priority")
    @validated = build_validated_subscriber_list(@subscribers)
    respond_to do |format|
      format.js {render :layout => false }
    end
  end


  #
  # used for retrieving the patients that match partially  the string entered in the search box
  # the returned code opens a jquery dialog box on the users screen under the search box.
  # /GET patients/search
  def ajax_search
    @patients = Patient.search(params[:search])

    respond_to do |format|
      format.js {render :layout => false }
    end
  end

  #
  # used for checking the entered patient name to see if it already exists.
  # this is called only from the new.html form
  def ajax_check_duplicate
    @new_patient = params[:patient]
    @patients = Patient.find(:all, :conditions => ["first_name = ? and last_name = ?", @new_patient[:first_name], @new_patient[:last_name] ])
    respond_to do |format|
      if !@patients.blank?
        format.js {render :layout => false }
      else
        format.js {render :nothing => true }
      end
    end
  end

  private

  def select_primary_codes_for_display
    if params[:provider_id]
      # whle in the screen, we changed to a different Provider
      @primary = @patient.patients_providers.find_by_provider_id(params[:provider_id])
      @primary_selection = Selector::PROVIDER
      @provider = @patient.providers.find(params[:provider_id])
      @primary_name = @provider.provider_name
      @rates = @provider.rates
      @mod_cpt_save = {:provider_id => params[:provider_id]}
    elsif params[:group_id]
      # whle in the screen, we changed to a different group
      @primary = @patient.patients_groups.find_by_group_id(params[:group_id])
      @primary_selection = Selector::GROUP
      @group = @patient.groups.find(params[:group_id])
      @primary_name = @group.group_name
      @rates = @group.rates
      @mod_cpt_save = {:group_id => params[:group_id]}
    elsif session[:group]
      #else if session[:group]
      @primary = @patient.patients_groups.find_by_group_id(session[:group])
      @primary_selection = Selector::GROUP
      @group = Group.find(session[:group])
      @primary_name = @group.group_name
      @rates = @group.rates
    elsif session[:provider]
      # if session[:provider]
      @primary = @patient.patients_providers.find_by_provider_id(session[:provider])
      @primary_selection = Selector::PROVIDER
      @provider = Provider.find(session[:provider])
      @primary_name = @provider.provider_name
      @rates = @provider.rates
    elsif !@patient.patients_providers.blank?
      #else if get the first provider
      @primary = @patient.patients_providers.first
      @primary_selection = Selector::PROVIDER
      @provider = @patient.providers.first
      @primary_name = @provider.provider_name
      @rates = @provider.rates
    elsif !@patient.patients_groups.blank?
      # else get the first group
      @primary = @patient.patients_groups.first
      @primary_selection = Selector::GROUP
      @group = @patient.groups.first
      @primary_name = @group.group_name
      @rates = @group.rates
    else
      # if no session variable set and no asociations set, then return nil
      @primary_selection = nil
      return nil
    end
    return @primary
  end


  def setup_static_variables
    @gender = Patient::GENDER
    @relationship = Patient::RELATIONSHIP
    @patient_status = Patient::PATIENT_STATUS
    @referral_list = ReferredType.find(:all)

    # prep for procedure and diagnosis code display
    @cpts_codes = CodesCpt.without_status :deleted, :archived
    @mod_codes = CodesModifier.without_status :deleted, :archived
    #place of service codes
    @pos_codes = CodesPos.without_status :deleted, :archived

  end

  #
  # using the supplied list of subscribers joined with sunscriber_valid table
  # build a validated array if the selected provider / group has had the subscribers insurance validated
  #
  def build_validated_subscriber_list(subscribers)
      # builds the array of @validated which contains all the subscribers for the patient and if the subscriber has been validated for the selected provider / or group
      # found will be true.  This allows easy displaying of proper buttons to perform validation of subscriber.
      validated = Array.new
      subscribers.each do |s|
        found = false; found_id = nil; in_network = SubscriberValid::NOT_VALIDATED; status = "Not Validated"
        s.subscriber_valids.each do |v|
          # polymorphic_validation could point to either the patients_provider or patients_group table
          polymorphic_validation = v.validable
          if @primary_selection == Selector::PROVIDER
            if v.validable_type == "PatientsProvider" && polymorphic_validation.provider_id == @provider.id
              found = true
              found_id = v.id
              in_network = v.in_network
              status = v.status
            end
          else
            if v.validable_type == "PatientsGroup" && polymorphic_validation.group_id == @group.id
              found = true
              found_id = v.id
              in_network = v.in_network
              status = v.status
            end
          end
        end   # end of subscriber_valids.each loop
        validated.push :ins_priority => s.ins_priority, :ins_name => s.insurance_company.name, :ins_id => s.insurance_company.id, :ins_address1 => s.insurance_company.address1,
                       :ins_address2 => s.insurance_company.address2, :ins_city => s.insurance_company.city, :ins_state => s.insurance_company.state, :ins_zip => s.insurance_company.zip,
                       :ins_main_phone => s.insurance_company.main_phone, :ins_main_description => s.insurance_company.main_phone_description, :ins_alt_phone => s.insurance_company.alt_phone,
                       :ins_alt_description => s.insurance_company.alt_phone_description, :ins_fax => s.insurance_company.fax_number,
                       :ins_policy => s.ins_policy, :subscriber_id => s.id, :found => found, :found_id => found_id, :in_network => in_network, :status => status
      end     # end of subscriber.each loop
    return validated
  end

end

