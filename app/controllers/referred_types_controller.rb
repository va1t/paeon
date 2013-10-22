class ReferredTypesController < ApplicationController
  # user must be logged into the system
  before_filter :authenticate_user!  
  authorize_resource
    
  # GET /referred_types
  # GET /referred_types.json
  def index
    @referred_types = ReferredType.all
    @title = "Type of Referrals"
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @referred_types }
    end
  end


  # GET /referred_types/new
  # GET /referred_types/new.json
  def new
    @referred_type = ReferredType.new
    @title = "New Type of Referrals"
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @referred_type }
    end
  end

  # GET /referred_types/1/edit
  def edit
    @referred_type = ReferredType.find(params[:id])
    @title = "Edit Type of Referrals"
  end


  # POST /referred_types
  # POST /referred_types.json
  def create
    @referred_type = ReferredType.new(params[:referred_type])
    @referred_type.created_user = current_user.login_name
    
    respond_to do |format|
      if @referred_type.save
        format.html { redirect_to referred_types_path, notice: 'Referred type was successfully created.' }
        format.json { render json: @referred_type, status: :created, location: @referred_type }
      else
        format.html { render action: "new" }
        format.json { render json: @referred_type.errors, status: :unprocessable_entity }
      end
    end
  end


  # PUT /referred_types/1
  # PUT /referred_types/1.json
  def update
    @referred_type = ReferredType.find(params[:id])
    @referred_type.updated_user = current_user.login_name

    respond_to do |format|
      if @referred_type.update_attributes(params[:referred_type])
        format.html { redirect_to referred_types_path, notice: 'Referred type was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @referred_type.errors, status: :unprocessable_entity }
      end
    end
  end
  

  # DELETE /referred_types/1
  # DELETE /referred_types/1.json
  def destroy
    @referred_type = ReferredType.find(params[:id])
    @referred_type.destroy

    respond_to do |format|
      format.html { redirect_to referred_types_path }
      format.json { head :no_content }
    end
  end
end
