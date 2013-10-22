class InvoiceMaintenanceController < ApplicationController
  # user must be logged into the system
  before_filter :authenticate_user!  
  #authorize on the invoice class, maintenance does not have a supporting model
  authorize_resource :class => Invoice
  
  #
  # GET /invoice_maintenance/index
  #
  def index
    @groups = Group.all(:order => :group_name)
    @providers = Provider.all(:order => [:last_name, :first_name])
    @title = "Client Fees Maintenance"
    if params[:provider_id]
      @object = Provider.find(params[:provider_id])
      @name = @object.provider_name
      @object_id = @object.id
      @object.selector = Selector::PROVIDER
      @display_links = true
    elsif params[:group_id]
      @object = Group.find(params[:group_id])
      @name = @object.group_name      
      @object_id = @object.id
      @object.selector = Selector::GROUP
      @display_links = true
    else
      @object = nil  
      @object_id = nil
    end    
    @invoice_method = InvoiceCalculation::METHODS
    @payment_terms = InvoiceFlow::PAYMENT_TERMS
    
    respond_to do |format|
      format.html
      format.json { render :json => {:groups =>@groups, :providers => @providers }}
    end
  end


  def update
    @groups = Group.all(:order => :group_name)
    @providers = Provider.all(:order => [:last_name, :first_name])
    @title = "Client Fees Maintenance"
    if !params[:provider].blank?
      @object = Provider.find(params[:id])
      @param_to_save = params[:provider]
      @name = @object.provider_name
    elsif !params[:group].blank?
      @object = Group.find(params[:id])
      @param_to_save = params[:group]
      @name = @object.group_name
    end
    respond_to do |format|
      if @object.update_attributes(@param_to_save)
        format.html {redirect_to invoice_maintenance_index_path, notice: "Fees were successfully saved for #{@name}"}
      else
        @invoice_method = InvoiceCalculation::METHODS
        format.html { render action: "index" } 
      end
    end
  end
  
  
  def show
    @groups = Group.all(:order => :group_name)
    @providers = Provider.all(:order => [:last_name, :first_name])
    @title = "All Group / Provider Fees"
    
    respond_to do |format|
      format.html
      format.json { render :json => {:groups =>@groups, :providers => @providers }}
    end    
  end


  def print
    @fees = CustomerFeesReport.new
    @fees.build

    respond_to do |format|
      format.pdf { send_data @fees.render, :filename => "customer_fees.pdf", :type => "application/pdf" }
      format.html { send_data @fees.render, :filename => "customer_fees.pdf", :type => "application/pdf" }
    end
  end
  
  
  def ajax_index
    if !params[:group_id].blank?
      @object = Group.find(params[:group_id])
      @name = @object.group_name
      @object.selector = Selector::GROUP
    elsif !params[:provider_id].blank?
      @object = Provider.find(params[:provider_id])
      @name = @object.provider_name
      @object.selector = Selector::PROVIDER
    end
    @invoice_method = InvoiceCalculation::METHODS
    @payment_terms = InvoiceFlow::PAYMENT_TERMS
    @display_links = true
    
    respond_to do |format|
      format.html {render :nothing => true}
      format.js {render :layout => false }
    end
  end
end
