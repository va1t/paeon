class AccidentTypesController < ApplicationController
  # user must be logged into the system
  before_filter :authenticate_user!
  authorize_resource

  # GET /accident_types
  # GET /accident_types.json
  def index
    @accident_types = AccidentType.without_status :deleted, :archived
    @title = "Accident Types"
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @accident_types }
    end
  end


  # GET /accident_types/new
  # GET /accident_types/new.json
  def new
    @accident_type = AccidentType.new
    @title = "New Accident Type"

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @accident_type }
    end
  end


  # GET /accident_types/1/edit
  def edit
    @accident_type = AccidentType.find(params[:id])
    @title = "Editing Accident Type"
  end


  # POST /accident_types
  # POST /accident_types.json
  def create
    @accident_type = AccidentType.new(params[:accident_type])
    @accident_type.created_user = current_user.login_name

    respond_to do |format|
      if @accident_type.save
        @accident_type.lock_record if @accident_type.can_be_permanent?
        format.html { redirect_to accident_types_path, notice: 'Accident type was successfully created.' }
        format.json { render json: @accident_type, status: :created, location: @accident_type }
      else
        format.html { render action: "new" }
        format.json { render json: @accident_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /accident_types/1
  # PUT /accident_types/1.json
  def update
    @accident_type = AccidentType.find(params[:id])
    @accident_type.updated_user = current_user.login_name

    respond_to do |format|
      if @accident_type.update_attributes(params[:accident_type])
        @accident_type.lock_record if @accident_type.can_be_permanent?
        format.html { redirect_to accident_types_path, notice: 'Accident type was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @accident_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /accident_types/1
  # DELETE /accident_types/1.json
  def destroy
    @accident_type = AccidentType.find(params[:id])
    @accident_type.updated_user = current_user.login_name
    @accident_type.destroy

    respond_to do |format|
      format.html { redirect_to accident_types_path }
      format.json { head :no_content }
    end
  end
end
