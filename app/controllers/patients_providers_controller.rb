class PatientsProvidersController < ApplicationController
  # user must be logged into the system
  before_filter :authenticate_user! 
  authorize_resource
  
  # for managing the patient to Provider relationship and storing specific 
  # information needed on that relationship, ie: account numbers
  # standard names restful functions are for patient views & actions
  # names prepended with grp_ are the group views & actions
  # :tid = Provider_id, :cid = patient_id, :id = id for the specific relationship record

  # GET /patients_providers
  # GET /patients_providers.json
  def patient_index
    @patient = Patient.find(params[:id])
    @patients_providers = @patient.patients_providers(:joins => :Provider, :order => "Providers.last_name, Providers.first_name")
    @title = "Patient to Provider Relationship"
    session[:return_to] = patients_providers_patients_path(@patient)
    @show = true
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @patients_providers }
    end
  end


  def index
    @provider = Provider.find(params[:id])
    # if coming from the group to the Provider to patients, need ot display the grouppatients
    if session[:context] == GROUP
      @group = Group.find(session[:group])
      #@patients_providers = @group.patients_groups(:joins => :patient, :order => "patients.last_name ASC, patients.first_name ASC")
      # keep this query for the order to work.  Query above does not sort correctly
      @patients_providers = PatientsGroup.find_all_by_group_id(@group.id, :joins => :patient, :order => "patients.last_name ASC, patients.first_name ASC")
    else
      #@patients_providers = @provider.patients_providers(:joins => :patient, :order => "patients.last_name ASC, patients.first_name ASC")
      # keep this query for the order to work.  Query above does not sort correctly
      @patients_providers = PatientsProvider.find_all_by_provider_id(@provider.id, :joins => :patient, :order => "patients.last_name ASC, patients.first_name ASC")
    end
    @title = "Patient to Provider Relationship"
    session[:return_to] = patients_providers_path(@provider)
    set_patient_session
    
    respond_to do |format|
      format.html # index.html.erb      
      format.json { render json: @patients_providers }
    end    
  end
    
    
  # GET /patients_providers/1/edit
  def edit
    @patients_providers = PatientsProvider.find(params[:id])
    @provider = Provider.find(@patients_providers.provider_id)           
    @patient = Patient.find(@patients_providers.patient_id)
    @title = "Edit Patient to Provider Relationship"    
  end

  
  # PUT /patients_providers/1
  # PUT /patients_providers/1.json
  def update
    @patients_providers = PatientsProvider.find(params[:id])
    @patients_providers.created_user = current_user.login_name
    @patients_providers.updated_user = current_user.login_name
    
    if params[:patients_provider]
      #update the created and updated users for each iprocedures record   
      @iprocs = params[:patients_provider][:iprocedures_attributes]    
      if @iprocs
        @iprocs.each do |x, p|
          p[:created_user] = current_user.login_name if p[:created_user].blank?
          p[:updated_user] = current_user.login_name if p[:updated_user].blank?
        end
      end
    end

    respond_to do |format|
      if @patients_providers.update_attributes(params[:patients_provider])
        format.html { 
          if params[:provider_id]
            redirect_to patient_path(@patients_providers.patient_id, :provider_id => params[:provider_id]), notice: 'Association was successfully updated.' 
          else
            redirect_to session[:return_to], notice: 'Association was successfully updated.' 
          end
        }
        format.json { head :no_content }
      else
        format.html { render action: "edit" } #need to fix storing the correct request.referer
        format.json { render json: @patients_providers.errors, status: :unprocessable_entity }
      end
    end
  end
  
  
  # DELETE /patients_providers/1
  # DELETE /patients_providers/1.json
  def destroy
    @patients_providers = PatientsProvider.find(params[:id])
    @provider = @patients_providers.provider_id
    @patients_providers.destroy

    respond_to do |format|
      format.html { redirect_to session[:return_to], notice: "Association was removed"  }
      format.json { head :no_content }
    end
  end
  

  
  # for retrieving and selecting the next patient to work with in Insurance billing
  def ajax_next_patient
    begin
      if params[:commit]
        @ct = params[:patients_providers]
        @patient = Patient.find(@ct[:next_patient])
        set_patient_session(@patient.id, @patient.patient_name)
      else
        @patients_providers = PatientsProvider.find_all_by_Provider_id(session[:provider])                                      
        @patient = Patient.find_all_by_id(@patients_providers.collect{|c| c.patient_id} , :order => "last_name ASC, first_name ASC")      
      end
      
      respond_to do |format|
        format.html { redirect_to new_insurance_billing_path(:dos => session[:dos]) }
        format.js
      end
    rescue
      respond_to do |format|
        format.html { head :no_content }
        format.js { head :no_content }
      end
    end
  end
  
  #
  # for searching on a patient in a particular Provider
  #
  def ajax_search
    @provider = Provider.find(params[:provider])
    @patients = @provider.patients.search(params[:search])

    respond_to do |format|    
      format.js {render :layout => false }
    end    
  end
  
end
