class SystemInfosController < ApplicationController
  # user must be logged into the system
  before_filter :authenticate_user!  
  authorize_resource
  
  # GET /system_infos
  # GET /system_infos.json
  def index
    # check for a system infos record.  if it doesnt exist then 
    # create an intial blank record.  then redirect to edit.    
    @system_info = SystemInfo.first

    if @system_info == nil      
      @system_info = SystemInfo.new
      @system_info.created_user = current_user.login_name       
      @system_info.save
    end

    respond_to do |format|
      format.html { redirect_to edit_system_info_path(@system_info) }
      format.json { render json: @system_infos }
    end
  end


  # GET /system_infos/1/edit
  def edit
    @title = "System Registration / Information"
    @system_info = SystemInfo.find(params[:id])
    @system_info.created_user ||= current_user.login_name  #in case when setting upa new system the system_claim_identifier is entered manually.
    @system_info.updated_user = current_user.login_name
  end


  # PUT /system_infos/1
  # PUT /system_infos/1.json
  def update
    @system_info = SystemInfo.find(params[:id])
    @system_info.updated_user = current_user.login_name
    
    respond_to do |format|
      if @system_info.update_attributes(params[:system_info])
        format.html { redirect_to maint_index_path, notice: 'System info was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @system_info.errors, status: :unprocessable_entity }
      end
    end
  end

end
