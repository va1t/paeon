class ManagedCaresController < ApplicationController
  # user must be logged into the system
  before_filter :authenticate_user!  
  authorize_resource

  # GET /managed_cares
  # GET /managed_cares.json
  def index
    @patient = Patient.find(params[:patient_id])
    set_patient_session @patient.id, @patient.patient_name 
    @managed_cares = @patient.managed_cares.joins(:subscriber)
    @title = "Patient Managed Care Information"
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @managed_cares }
    end
  end

  # GET /managed_cares/1
  # GET /managed_cares/1.json
  def show
    @patient = Patient.find(params[:patient_id])
    set_patient_session @patient.id, @patient.patient_name 
    @managed_care = ManagedCare.find(params[:id])
    @show = true
    @title = "Patient Managed Care Information"

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @managed_care }
    end
  end

  # GET /managed_cares/new
  # GET /managed_cares/new.json
  def new
    @patient = Patient.find(params[:patient_id])
    set_patient_session @patient.id, @patient.patient_name 
    @managed_care = @patient.managed_cares.new
    @managed_care.patient_id = params[:patient_id]
    @subscriber = @patient.subscribers.all
    @title = "New Managed Care Information"
    @providers = @patient.providers
    @groups = @patient.groups    

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @managed_care }
    end
  end

  # GET /managed_cares/1/edit
  def edit
    @patient = Patient.find(params[:patient_id])
    set_patient_session @patient.id, @patient.patient_name 
    @managed_care = ManagedCare.find(params[:id])
    @subscriber = @patient.subscribers.all
    @title = "Edit Managed Care Information"
    @providers = @patient.providers
    @groups = @patient.groups    
  end

  # POST /managed_cares
  # POST /managed_cares.json
  def create
    @patient = Patient.find(params[:patient_id])    
    @managed_care = ManagedCare.new(params[:managed_care])
    @managed_care.created_user = current_user.login_name
    @subscriber = @patient.subscribers.all
    @providers = @patient.providers
    @groups = @patient.groups    
    
    respond_to do |format|
      if @managed_care.save
        format.html { redirect_to patient_managed_cares_path(:patient_id =>params[:patient_id]), notice: 'Managed care was successfully created.' }
        format.json { render json: @managed_care, status: :created, location: @managed_care }
      else
        format.html { render action: "new" }
        format.json { render json: @managed_care.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /managed_cares/1
  # PUT /managed_cares/1.json
  def update
    @patient = Patient.find(params[:patient_id])    
    @managed_care = ManagedCare.find(params[:id])
    @managed_care.updated_user = current_user.login_name
    @subscriber = @patient.subscribers.all
    @providers = @patient.providers
    @groups = @patient.groups    
    
    respond_to do |format|
      if @managed_care.update_attributes(params[:managed_care])
        format.html { redirect_back_or_default patient_managed_cares_path(:patient_id =>params[:patient_id]), notice: 'Managed care was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @managed_care.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /managed_cares/1
  # DELETE /managed_cares/1.json
  def destroy
    @managed_care = ManagedCare.find(params[:id])
    @managed_care.destroy

    respond_to do |format|
      format.html { redirect_to patient_managed_cares_path(:patient_id =>params[:patient_id]) }
      format.json { head :no_content }
    end
  end
end
