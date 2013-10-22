class InsuranceTypesController < ApplicationController
  # user must be logged into the system
  before_filter :authenticate_user!  
  authorize_resource
  
  # GET /insurance_types
  # GET /insurance_types.json
  def index
    @insurance_types = InsuranceType.all
    @title = "Types of Patient Insurance"
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @insurance_types }
    end
  end

  # GET /insurance_types/new
  # GET /insurance_types/new.json
  def new
    @insurance_type = InsuranceType.new
    @title = "New Insurance Type"
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @insurance_type }
    end
  end

  # GET /insurance_types/1/edit
  def edit
    @insurance_type = InsuranceType.find(params[:id])
    @title = "Editing Types of Insurance"
  end

  # POST /insurance_types
  # POST /insurance_types.json
  def create
    @insurance_type = InsuranceType.new(params[:insurance_type])
    @insurance_type.created_user = current_user.login_name
    
    respond_to do |format|
      if @insurance_type.save
        format.html { redirect_to insurance_types_path, notice: 'Insurance type was successfully created.' }
        format.json { render json: @insurance_type, status: :created, location: @insurance_type }
      else
        format.html { render action: "new" }
        format.json { render json: @insurance_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /insurance_types/1
  # PUT /insurance_types/1.json
  def update
    @insurance_type = InsuranceType.find(params[:id])
    @insurance_type.updated_user = current_user.login_name
    
    respond_to do |format|
      if @insurance_type.update_attributes(params[:insurance_type])
        format.html { redirect_to insurance_types_path, notice: 'Insurance type was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @insurance_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /insurance_types/1
  # DELETE /insurance_types/1.json
  def destroy
    @insurance_type = InsuranceType.find(params[:id])
    @insurance_type.destroy

    respond_to do |format|
      format.html { redirect_to insurance_types_path }
      format.json { head :no_content }
    end
  end
end
