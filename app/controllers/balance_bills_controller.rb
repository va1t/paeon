class BalanceBillsController < ApplicationController  
  # user must be logged into the system
  before_filter :authenticate_user!  
  authorize_resource


  # GET /balance_bills/
  # GET /balance_bills/.json
  def index
    reset_session
    @balance_bills = BalanceBill.includes(:patient).pending.order("patients.last_name, patients.first_name")
    @title = "Balance Bills"
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => {:balance_bill => @balance_bills } }
    end
  end


  # GET /balance_bills/new
  # GET /balance_bills/new.json
  def new
    # select the patients with a balance bill session not attached to a balance bill
    # want just the unique patient's and have them in an array sorted by name and thier id
    @pending = BalanceBillSession.pending
    @pending.uniq!{|c| c.provider_id}  
    @unique_providers = @pending.collect{ |c| [c.provider.provider_name, c.provider_id]}.sort    
    
    # set the patient & balance bill var to nil; will populate them with ajax call
    @unique_patients = ["",""]
    @patient = nil
    @balance_bill = nil
    @title = "Create New Balance Bill"
    @display_sidebar = true
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { head :no_content }
    end    
  end

  
  # GET /balance_bills/edit
  # GET /balance_bills/edit.json
  def edit
    @balance_bill = BalanceBill.find(params[:id])
    @patient = @balance_bill.patient
    @title = "Edit Balance Bill"
    @display_sidebar = true
    
    respond_to do |format|
      format.html # edit.html.erb
      format.json { head :no_content }
    end    
  end

  
  # POST /balance_bills/1
  # POST /balance_bills/1.json
  def create
    @balance_bill = BalanceBill.new(params[:balance_bill])
    @balance_bill.created_user = current_user.login_name
    @patient = @balance_bill.patient
    @title = "Create New Balance Bill"
    @display_sidebar = true

    respond_to do |format|
      if @balance_bill.save
        format.html { 
          if params[:commit] == "Update"
            render "edit"
          else
            redirect_to balance_bills_path  
          end           
        }
        format.json { head :no_content }        
      else
        @patient = Patient.find(@balance_bill.patient_id)
        format.html { render "new" }
        format.json { head :no_content }
      end
    end    

  end


  # PUT /balance_bills/1
  # PUT /balance_bills/1.json
  def update
    @balance_bill = BalanceBill.find(params[:id])
    @balance_bill.updated_user = current_user.login_name
    @patient = @balance_bill.patient
    @title = "Edit Balance Bill"
    @display_sidebar = true

    respond_to do |format|
      if @balance_bill.update_attributes(params[:balance_bill])
        format.html { 
          if params[:commit] == "Update"            
            render "edit"
          else
            redirect_to balance_bills_path  
          end           
        }
        format.json { head :no_content }
      else
        @patient = Patient.find(@balance_bill.patient_id)
        format.html { render "edit" }
        format.json { head :no_content }
      end
    end    
  end
  

  # DELETE /balance_bills/1
  # DELETE /balance_bills/1.json
  def destroy
    @balance_bill = BalanceBill.find(params[:id])
    @balance_bill.updated_user = current_user.login_name
    @balance_bill.destroy
    
    respond_to do |format|
      format.html { redirect_to balance_bills_path }
      format.json { head :no_content }
    end        
  end
  
  # 
  # builds and displays the selected balance bill as a pdf
  #
  def show_pdf
    @balance_bill = BalanceBillInvoice.new(params[:id])
    @balance_bill.build    
    respond_to do |format|
      format.pdf { send_data @balance_bill.render, :filename => "balance_bill.pdf", :type => "application/pdf" }
    end

  end
  
  
  def ajax_select
    # retreive the selected patient and build a new balance bill with all of thier unbilled sessions
    if params[:provider_id]
      @pending = BalanceBillSession.pending.where("balance_bill_sessions.provider_id = ?", params[:provider_id])
      @pending.uniq!{|c| c.patient_id}  
      @unique_patients = @pending.collect{ |c| [c.patient.patient_name, c.patient_id]}.sort   
    else
      params[:patient_id] = ""   #didnt select a provider, so null out the patient parameter
      @unique_patients = nil
    end    
    
    if !params[:patient_id].blank?
      @patient = Patient.find(params[:patient_id])
      @balance_bill = @patient.balance_bills.new()
    else
      @patient = nil
      @balance_bill = nil
    end
    
    respond_to do |format|
      format.js
    end
  end
  
end
