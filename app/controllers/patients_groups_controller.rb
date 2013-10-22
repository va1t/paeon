class PatientsGroupsController < ApplicationController
  # user must be logged into the system
  before_filter :authenticate_user! 
  authorize_resource
  
  # for managing the patient to group relationship and storing specific 
  # information needed on that relationship, ie: account numbers
  # standard names restful functions are for patient views & actions
  # names prepended with grp_ are the group views & actions
  # :gid = group_id, :cid = patient_id, :id = id for the specific relationship record
  
  # GET /patients_groups/:cid
  # GET /patients_groups/:cid.json
  # list all group relationships for patient
  def patient_index
    @patient = Patient.find(params[:id])
    @patients_groups = @patient.patients_groups(:joins => :group, :order => "group.group_name ASC")
    @title = "Patient to Group Relationship"
    session[:return_to] = patients_groups_patients_path(@patient)
    @show = true
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @patients_groups }
    end
  end

  # GET /patients_groups/:id
  # GET /patients_groups.json/:id  
  # list all patient relationships for group
  def index
    @group = Group.find(params[:id])
    #@patients_groups = @group.patients_groups(:joins => :patient, :order => "patients.last_name ASC, patients.first_name ASC")
    # keep this query for the order to work.  Query above does not sort correctly
    @patients_groups = PatientsGroup.find_all_by_group_id(@group.id, :joins => :patient, :order => "patients.last_name ASC, patients.first_name ASC")    
    @title = "Patient to Group Relationship"
    session[:return_to] = patients_groups_path(@group)
    
    respond_to do |format|
      format.html # grp_index.html.erb
      format.json { render json: @patients_groups }
    end
  end


  # GET /patients_groups/edit/:id
  # edit the specific relationship
  def edit
    @patients_groups = PatientsGroup.find(params[:id])
    @group = Group.find(@patients_groups.group_id)
    @patient = Patient.find(@patients_groups.patient_id)
    session[:return_to] = request.referer
    @title = "Edit Patient to Group Relationship"
  end

  
  # PUT /patients_groups/:id
  # PUT /patients_groups/:id.json
  def update
    @patients_groups = PatientsGroup.find(params[:id])
    @patients_groups.created_user = current_user.login_name
    @patients_groups.updated_user = current_user.login_name

    if params[:patients_group]
      #update the created and updated users for each iprocedures record   
      @iprocs = params[:patients_group][:iprocedures_attributes]    
      if @iprocs
        @iprocs.each do |x, p|
          p[:created_user] = current_user.login_name if p[:created_user].blank?
          p[:updated_user] = current_user.login_name if p[:updated_user].blank?
        end
      end
    end

    respond_to do |format|
      if @patients_groups.update_attributes(params[:patients_group])
        format.html { 
          if params[:group_id]
            redirect_to patient_path(@patients_groups.patient_id, :group_id => params[:group_id]), notice: 'Association was successfully updated.' 
          else
            redirect_to session[:return_to], notice: 'Association was successfully updated.' 
          end
        }
        format.json { head :no_content }
      else
        format.html { render action: "edit" } #need to fix storing the correct request.referer 
        format.json { render json: @patients_groups.errors, status: :unprocessable_entity }
      end
    end
  end

  
  # DELETE /patients_groups/:id
  # DELETE /patients_groups/:id.json
  def destroy
    @patients_groups = PatientsGroup.find(params[:id])
    @group = @patients_groups.group_id
    @patients_groups.destroy

    respond_to do |format|
      format.html { redirect_to session[:return_to], notice: "Association was removed" }
      format.json { head :no_content }
    end
  end
  

  
  # for retrieving and selecting the next patient to work with in Insurance billing
  def ajax_next_patient
    begin
      if params[:commit]
        @ct = params[:patients_groups]
        @patient = Patient.find(@ct[:next_patient])
        set_patient_session(@patient.id, @patient.patient_name)
      else
        @patients_groups = PatientsGroup.find_all_by_group_id(session[:group]) 
        @patient = Patient.find_all_by_id(@patients_groups.collect{|c| c.patient_id}, :order => "last_name ASC, first_name ASC")      
      end
      
      #the get is an ajax call, th post is a redirect to new insurance billing
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
  # for searching on a patient within the group
  #
  def ajax_search
    @group = Group.find(params[:group])
    @patients = @group.patients.search(params[:search])
    
    respond_to do |format|    
      format.js {render :layout => false }
    end        
  end
  
end
