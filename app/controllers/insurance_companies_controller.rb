class InsuranceCompaniesController < ApplicationController
  # user must be logged into the system
  before_filter :authenticate_user!  
  authorize_resource

  # GET /insurance_cos
  # GET /insurance_cos.json
  def index
    @insurance_cos = InsuranceCompany.find(:all, :order => :name)
    @title = "Insurance Companies"
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @insurance_cos }
    end
  end
  

  # GET /insurance_cos/1
  # GET /insurance_cos/1.json
  def show
    @insurance_co = InsuranceCompany.find(params[:id])
    @show = true
    if params[:pr]
      @pr = params[:pr]
    end
    @title = "Insurance Companies"
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @insurance_co }
    end
  end
  

  # GET /insurance_cos/new
  # GET /insurance_cos/new.json
  def new
    @insurance_co = InsuranceCompany.new
    @title = "Insurance Companies"
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @insurance_co }
    end
  end


  # GET /insurance_cos/1/edit
  def edit
    @insurance_co = InsuranceCompany.find(params[:id])
    @title = "Insurance Companies"
  end

  # POST /insurance_cos
  # POST /insurance_cos.json
  def create
    @insurance_co = InsuranceCompany.new(params[:insurance_company])
    @insurance_co.created_user = current_user.login_name
    
    respond_to do |format|
      if @insurance_co.save
        format.html { redirect_to @insurance_co, notice: 'Insurance co was successfully created.' }
        format.json { render json: @insurance_co, status: :created, location: @insurance_co }
      else
        format.html { render action: "new" }
        format.json { render json: @insurance_co.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /insurance_cos/1
  # PUT /insurance_cos/1.json
  def update
    @insurance_co = InsuranceCompany.find(params[:id])
    @insurance_co.updated_user = current_user.login_name
    
    respond_to do |format|
      if @insurance_co.update_attributes(params[:insurance_company])
        format.html { redirect_back_or_default @insurance_co, notice: 'Insurance co was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @insurance_co.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /insurance_cos/1
  # DELETE /insurance_cos/1.json
  def destroy
    @insurance_co = InsuranceCompany.find(params[:id])    

    respond_to do |format|
      if @insurance_co.destroy
        format.html { redirect_to insurance_companies_url }
        format.json { head :no_content }
      else       
        format.html { 
          @msg = ""
          @insurance_co.errors.full_messages.each {|m| @msg += m }                   
          redirect_to insurance_companies_url, notice: @msg }
        format.json { head :no_content }
      end
    end
  end
end
