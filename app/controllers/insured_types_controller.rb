class InsuredTypesController < ApplicationController
  # user must be logged into the system
  before_filter :authenticate_user!  
  authorize_resource
  
  # GET /insured_types
  # GET /insured_types.json
  def index
    @insured_types = InsuredType.all
    @title = "Types of Insured Patients"
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @insured_types }
    end
  end

  # GET /insured_types/new
  # GET /insured_types/new.json
  def new
    @insured_type = InsuredType.new
    @title = "New Type of Insured Patient"
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @insured_type }
    end
  end

  # GET /insured_types/1/edit
  def edit
    @insured_type = InsuredType.find(params[:id])
    @title = "Editing Type of Insured Patient"
  end

  # POST /insured_types
  # POST /insured_types.json
  def create
    @insured_type = InsuredType.new(params[:insured_type])
    @insured_type.created_user = current_user.login_name
    
    respond_to do |format|
      if @insured_type.save
        format.html { redirect_to insured_types_path, notice: 'Insured type was successfully created.' }
        format.json { render json: @insured_type, status: :created, location: @insured_type }
      else
        format.html { render action: "new" }
        format.json { render json: @insured_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /insured_types/1
  # PUT /insured_types/1.json
  def update
    @insured_type = InsuredType.find(params[:id])
    @insured_type.updated_user = current_user.login_name
    
    respond_to do |format|
      if @insured_type.update_attributes(params[:insured_type])
        format.html { redirect_to insured_types_path, notice: 'Insured type was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @insured_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /insured_types/1
  # DELETE /insured_types/1.json
  def destroy
    @insured_type = InsuredType.find(params[:id])
    @insured_type.destroy

    respond_to do |format|
      format.html { redirect_to insured_types_path }
      format.json { head :no_content }
    end
  end
end
