class ProvidersController < ApplicationController
      # user must be logged into the system
  before_filter :authenticate_user!
  authorize_resource

  def index
    if session[:context] == GROUP
      @group = Group.find(session[:group])
      @providers = @group.providers.order(:last_name, :first_name)
    else
      @providers = Provider.order(:last_name, :first_name).all
    end
    set_provider_session
    @title = "Provider Listing"

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @providers }
    end
  end


  def show
    @provider = Provider.find(params[:id])
    @groups = @provider.groups
    set_provider_session @provider.id, @provider.provider_name
    @offices = @provider.offices
    groupids = @groups.map {|g| g.id}
    @group_offices = Office.find(:all, :conditions => {:officeable_type => "Group", :officeable_id => [groupids] })
    @title = "Provider Details:"
    @show = true
    @display_sidebar = true

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @provider }
    end
  end


  def new
    set_provider_session
    if  params[:provider_id]
      @provider = Provider.find(params[:provider_id]).dup
      @provider.first_name = ""
      @provider.last_name = ""
      @provider.npi = ""
      @provider.ssn_number = ""
      @provider.license_number = ""
    else
      @provider = Provider.new
    end
    @title = "New Provider"

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @provider }
    end
  end


  def create
    @provider = Provider.new(params[:provider])
    @provider.created_user = current_user.login_name

    respond_to do |format|
      if @provider.save
        set_provider_session @provider.id, @provider.provider_name
        format.html { redirect_to new_provider_office_path(@provider), :notice => 'Provider was successfully created.' }
        format.json { render json: @provider, status: :created, location: @provider }
      else
        format.html { render action: "new" }
        format.json { render json: @provider.errors, status: :unprocessable_entity }
      end
    end
  end


  def edit
    @provider = Provider.find(params[:id])
    set_provider_session @provider.id, @provider.provider_name
    session[:return_to] = provider_path(params[:id])
    session[:on_error] = 'edit'
    @title = "Edit Provider"
  end


  def associate
    @provider = Provider.find(params[:id])
    @all_groups = Group.find(:all, :order => :group_name)
    @groups = @provider.groups
    @title = "Associate Provider to Groups"
    @associate = true
    set_provider_session @provider.id, @provider.provider_name
    session[:return_to] = provider_path(params[:id])
    session[:on_error] = 'associate'
  end


  def patient_associate
    @provider = Provider.find(params[:id])
    @patients = Patient.all(:order => [:last_name, :first_name])
    set_provider_session @provider.id, @provider.provider_name
    @title = "Create Provider to Patient Associations"
    @associate = true

    session[:return_to] =  patients_providers_path(@provider)
    session[:on_error] = 'patient_associate'
  end


  def update
    @provider = Provider.find(params[:id])
    @provider.updated_user = current_user.login_name
    set_provider_session @provider.id, @provider.provider_name

    respond_to do |format|
      if @provider.update_attributes( params[:provider] )
        format.html { redirect_back_or_default provider_path(@provider), :notice => 'Provider and Associations were successfully updated.' }
        format.json { head :no_content }
      else
        format.html {
          @all_groups = Group.find(:all)
          @groups = @provider.groups
          render action: session[:on_error] }
        format.json { render json: @patient.errors, status: :unprocessable_entity }
      end
    end
  end


  def destroy
    @provider = Provider.find(params[:id])
    @provider.destroy
    set_provider_session

    respond_to do |format|
      format.html { redirect_to providers_path }
      format.json { head :no_content }
    end
  end


  #
  # used for retrieving the patients that match partially  the string entered in the search box
  # the returned code opens a jquery dialog box on the users screen under the search box.
  # /GET patients/search
  def ajax_search
    @providers = Provider.search(params[:search])

    respond_to do |format|
      format.js {render :layout => false }
    end
  end
end
