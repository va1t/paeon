class GroupsController < ApplicationController
  # user must be logged into the system
  before_filter :authenticate_user!  
  authorize_resource
 
  def index
    @groups = Group.order(:group_name).all
    set_group_session
    @title = "Group Listing"
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @groups }
    end
  end
  
  
  def show
    @group = Group.find(params[:id])
    set_group_session @group.id, @group.group_name
    @title = "Group Details:"
    
    @providers = @group.providers
    @offices = @group.offices
    @show = true
    @display_sidebar = true
    
    logger.debug "Group: #{@group.group_name}, #{@group.id}"
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @group }
    end
  end
  
  
  def new
    @group = Group.new
    set_group_session
    @title = "New Group Provider"
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @group }
    end    
  end
  
  
  def create
    @group = Group.new(params[:group])        
    @group.created_user = current_user.login_name
            
    respond_to do |format|
      if @group.save        
        set_group_session @group.id, @group.group_name
        format.html { redirect_to new_group_office_path(@group), notice: 'Group was successfully created.' }
        format.json { render json: @group, status: :created, location: @group }
      else
        format.html { render action: "new" }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end
  
  
  def edit
    @group = Group.find(params[:id])
    set_group_session @group.id, @group.group_name
    @title = "Edit Group"
    session[:return_to] = group_path(params[:id])
    session[:on_error] = 'edit'
  end
  
    
  def associate
    @group = Group.find(params[:id])
    @provider = @group.providers
    @all_providers = Provider.find(:all, :order => [:last_name, :first_name])
    @title = "Create Group to Provider Associations"
    @associate = true
    set_group_session @group.id, @group.group_name
    
    session[:return_to] = group_path(params[:id])
    session[:on_error] = 'associate'
  end  


  def patient_associate
    @group = Group.find(params[:id])
    @patients = Patient.all(:order => [:last_name, :first_name])
    set_group_session @group.id, @group.group_name          
    @title = "Create Group to Patient Associations"
    @associate = true
    
    session[:return_to] = patients_groups_path(@group)
    session[:on_error] = 'patient_associate'
  end

  
  def update
    @group = Group.find(params[:id])    
    @group.updated_user = current_user.login_name
    set_group_session @group.id, @group.group_name
    
    respond_to do |format|
      if @group.update_attributes(params[:group])
        format.html { redirect_to session[:return_to], :notice => 'Group and Associations was successfully updated.' }
        format.json { head :no_content }
      else
        format.html {      
          @provider = @group.providers
          @all_providers = Provider.find(:all)
          render action: session[:on_error] }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

      
  def destroy
    @group = Group.find(params[:id])
    @group.destroy
    set_group_session
    
    respond_to do |format|
      format.html { redirect_to groups_path }
      format.json { head :no_content }
    end    
  end


  #
  # used for retrieving the patients that match partially  the string entered in the search box 
  # the returned code opens a jquery dialog box on the users screen under the search box.
  # /GET patients/search
  def ajax_search
    @groups = Group.search(params[:search])
    
    respond_to do |format|    
      format.js {render :layout => false }
    end    
  end
end
