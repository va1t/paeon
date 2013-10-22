class OfficeTypesController < ApplicationController
  # user must be logged into the system
  before_filter :authenticate_user!  
  authorize_resource
  
  # GET /office_types
  # GET /office_types.json
  def index
    @office_types = OfficeType.all
    @title = "Types of Offices"
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @office_types }
    end
  end


  # GET /office_types/new
  # GET /office_types/new.json
  def new
    @office_type = OfficeType.new
    @title = "New Office Type"
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @office_type }
    end
  end

  # GET /office_types/1/edit
  def edit
    @office_type = OfficeType.find(params[:id])
    @title = "Editing Types of Offices"
  end

  # POST /office_types
  # POST /office_types.json
  def create
    @office_type = OfficeType.new(params[:office_type])
    @office_type.created_user = current_user.login_name
    
    respond_to do |format|
      if @office_type.save
        format.html { redirect_to office_types_path, notice: 'Office type was successfully created.' }
        format.json { render json: @office_type, status: :created, location: @office_type }
      else
        format.html { render action: "new" }
        format.json { render json: @office_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /office_types/1
  # PUT /office_types/1.json
  def update
    @office_type = OfficeType.find(params[:id])
    @office_type.updated_user = current_user.login_name
    
    respond_to do |format|
      if @office_type.update_attributes(params[:office_type])        
        format.html { redirect_to office_types_path, notice: 'Office type was successfully updated.' }
        format.json { head :no_content }
      else        
        format.html { render action: "edit" }
        format.json { render json: @office_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /office_types/1
  # DELETE /office_types/1.json
  def destroy
    @office_type = OfficeType.find(params[:id])
    @office_type.destroy

    respond_to do |format|
      format.html { redirect_to office_types_path }
      format.json { head :no_content }
    end
  end
end
