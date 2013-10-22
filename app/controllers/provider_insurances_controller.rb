class ProviderInsurancesController < ApplicationController
  # user must be logged into the system
  before_filter :authenticate_user!    
  authorize_resource
  
  def index
    @providerable, @name = find_polymorphic
    @provider = @providerable.provider_insurances
    @title = @name.titleize + " Provider Insurance Listing"
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @provider }
    end    
  end


  # GET /provider_insurances/1
  # GET /provider_insurances/1.json
  def show
    @providerable, @name = find_polymorphic
    @provider = ProviderInsurance.find(params[:id])
    @title = @name.titleize + " Provider Insurance"
    @show = true
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @provider }
    end
  end


  # GET /provider_insurances/new
  # GET /provider_insurances/new.json
  def new
    @providerable, @name = find_polymorphic
    @provider = ProviderInsurance.new
    @title = @name.titleize + " New Provider Insurance"
    @all_insurance_company = InsuranceCompany.find(:all, :order => :name)
    @edit = true
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @provider }
    end
  end


  # GET /provider_insurances/1/edit
  def edit
    @providerable, @name = find_polymorphic
    @provider = ProviderInsurance.find(params[:id])
    @title = @name.titleize + " Edit Provider Insurance"
    @all_insurance_company = InsuranceCompany.find(:all, :order => :name)
    @edit = true
  end


  # POST /provider_insurances
  # POST /provider_insurances.json
  def create
    @providerable, @name = find_polymorphic
    @provider = @providerable.provider_insurances.build(params[:provider_insurance])
    @provider.created_user = current_user.login_name
    @all_insurance_company = InsuranceCompany.all
        
    respond_to do |format|
      if @provider.save
        format.html { redirect_to polymorphic_path([@providerable, @provider]), notice: 'Provider insurance was successfully created.' }
        format.json { render json: @provider, status: :created, location: @provider }
      else
        format.html { render action: "new" }
        format.json { render json: @provider.errors, status: :unprocessable_entity }
      end
    end
  end


  # PUT /provider_insurances/1
  # PUT /provider_insurances/1.json
  def update
    @providerable, @name = find_polymorphic
    @provider = ProviderInsurance.find(params[:id])    
    @provider.updated_user = current_user.login_name         
   
    respond_to do |format|
      if @provider.update_attributes(params[:provider_insurance])
        format.html { redirect_to polymorphic_path([@providerable, @provider]), notice: 'Provider insurance was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @provider.errors, status: :unprocessable_entity }
      end
    end
  end


  # DELETE /provider_insurances/1
  # DELETE /provider_insurances/1.json
  def destroy
    @providerable, @name = find_polymorphic
    @provider = ProviderInsurance.find(params[:id])    
    @provider.destroy

    respond_to do |format|
      format.html { redirect_to polymorphic_path([@providerable, :provider_insurances]) }
      format.json { head :no_content }
    end
  end
  

end
