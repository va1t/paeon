class PatientInjuriesController < ApplicationController
  # user must be logged into the system
  before_filter :authenticate_user!  
  authorize_resource
  
  
  # GET /patient_injuries
  # GET /patient_injuries.json
  def index
    @patient = Patient.find(params[:patient_id])
    @patient_injuries = @patient.patient_injuries
    @title = "Patient Histories"
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @patient_injuries }
    end
  end

  # GET /patient_injuries/1
  # GET /patient_injuries/1.json
  def show
    @patient = Patient.find(params[:patient_id])
    @patient_injury = @patient.patient_injuries.find(params[:id])
    @show = true
    @display_sidebar = true
    @title = "Patient History"
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @patient_injury }
    end
  end


  # GET /patient_injuries/new
  # GET /patient_injuries/new.json
  def new
    @patient = Patient.find(params[:patient_id])
    @patient_injury = @patient.patient_injuries.new    
    @patient_injury.patient_id = params[:patient_id]
    @accident_types = AccidentType.all
    @title = "New Patient History"
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @patient_injury }
    end
  end


  # GET /patient_injuries/1/edit
  def edit
    @patient = Patient.find(params[:patient_id])
    @patient_injury = @patient.patient_injuries.find(params[:id])
    @accident_types = AccidentType.all
    @title = "Edit Patient History"
  end


  # POST /patient_injuries
  # POST /patient_injuries.json
  def create
    @patient = Patient.find(params[:patient_id])
    @patient_injury = @patient.patient_injuries.new(params[:patient_injury])
    @patient_injury.created_user = current_user.login_name
    
    respond_to do |format|
      if @patient_injury.save
        format.html { redirect_to patient_patient_injuries_path(params[:patient_id]), notice: 'Patient history was successfully created.' }
        format.json { render json: @patient_injury, status: :created, location: @patient_injury }
      else
        @accident_types = AccidentType.all
        format.html { render action: "new" }
        format.json { render json: @patient_injury.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /patient_injuries/1
  # PUT /patient_injuries/1.json
  def update
    @patient = Patient.find(params[:patient_id])
    @patient_injury = @patient.patient_injuries.find(params[:id])
    @patient_injury.updated_user = current_user.login_name
    
    respond_to do |format|
      if @patient_injury.update_attributes(params[:patient_injury])
        format.html { redirect_to patient_patient_injuries_path(params[:patient_id]), notice: 'Patient history was successfully updated.' }
        format.json { head :no_content }
      else
        @accident_types = AccidentType.all
        format.html { render action: "edit" }
        format.json { render json: @patient_injury.errors, status: :unprocessable_entity }
      end
    end
  end


  # DELETE /patient_injuries/1
  # DELETE /patient_injuries/1.json
  def destroy
    @patient_injury = PatientInjury.find(params[:id])
    @patient_injury.destroy

    respond_to do |format|
      format.html { redirect_to patient_patient_injuries_path(params[:patient_id]) }
      format.json { head :no_content }
    end
  end
end
