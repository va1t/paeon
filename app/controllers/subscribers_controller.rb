class SubscribersController < ApplicationController
  # user must be logged into the system
  before_filter :authenticate_user!  
  authorize_resource
  
  # GET /subscribers
  # GET /subscribers.json
  def index
    @patient = Patient.find(params[:patient_id])
    @subscribers = @patient.subscribers.find(:all, :include => [:insurance_company], :order => "ins_priority")
    @title = "Patient Insurance Information"
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @subscribers }
    end
  end


  # GET /subscribers/1
  # GET /subscribers/1.json
  def show
    @patient = Patient.find(params[:patient_id])
    @subscriber = @patient.subscribers.find(params[:id], :include => [:insurance_company])
    @managed_cares = @subscriber.managed_cares
    @show = true
    @display_sidebar = true
    @title = "Patient Insurance Information"
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @subscriber }
    end
  end


  # GET /subscribers/new
  # GET /subscribers/new.json
  def new
    @patient = Patient.find(params[:patient_id])
    @subscriber = @patient.subscribers.new
    @subscriber.patient_id = params[:patient_id]
    setup_variables
    @title = "New Patient Insurance Information"
    @new_edit = true
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @subscriber }
    end
  end


  # GET /subscribers/1/edit
  def edit
    @patient = Patient.find(params[:patient_id])
    @subscriber = @patient.subscribers.find(params[:id])
    setup_variables
    @title = "Edit Patient Insurance Information"
    @new_edit = true
  end


  # POST /subscribers
  # POST /subscribers.json
  def create
    @patient = Patient.find(params[:patient_id])
    @subscriber = @patient.subscribers.new(params[:subscriber])
    @subscriber.created_user = current_user.login_name
    
    respond_to do |format|
      if @subscriber.save
        format.html { redirect_to patient_subscribers_path(params[:patient_id]), notice: 'Patient insured was successfully created.' }
        format.json { render json: @subscriber, status: :created, location: @subscriber }
      else
        setup_variables
        format.html { render action: "new" }
        format.json { render json: @subscriber.errors, status: :unprocessable_entity }
      end
    end
  end


  # PUT /subscribers/1
  # PUT /subscribers/1.json
  def update
    @patient = Patient.find(params[:patient_id])
    @subscriber = @patient.subscribers.find(params[:id])
    @subscriber.updated_user = current_user.login_name
    
    respond_to do |format|
      if @subscriber.update_attributes(params[:subscriber])
        format.html { redirect_to patient_subscribers_path(params[:patient_id]), notice: 'Patient insured was successfully updated.' }
        format.json { head :no_content }
      else
        setup_variables       
        format.html { render action: "edit" }
        format.json { render json: @subscriber.errors, status: :unprocessable_entity }
      end
    end
  end


  # DELETE /subscribers/1
  # DELETE /subscribers/1.json
  def destroy
    @subscriber = Subscriber.find(params[:id])
    @subscriber.destroy

    respond_to do |format|
      format.html { redirect_to patient_subscribers_path(params[:patient_id]) }
      format.json { head :no_content }
    end
  end
  
  def ajax_addr    
    @subscriber = params[:subscriber]
    @patient = Patient.find(@subscriber[:patient_id])        
  end
  
  def ajax_subscriber
    @subscriber = params[:subscriber]
    @patient = Patient.find(@subscriber[:patient_id])        
  end
  
  private
  
  def setup_variables
    @insured_types = InsuredType.all
    @insurance_types = InsuranceType.all   
    @insurance_priority = Subscriber::INSURANCE_PRIORITY
    @all_insurance_company = InsuranceCompany.find(:all, :order => :name)
  end
end
