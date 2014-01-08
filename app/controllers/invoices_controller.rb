class InvoicesController < ApplicationController
  # user must be logged into the system
  before_filter :authenticate_user!
  authorize_resource


  # GET /invoices
  # GET /invoices.json
  def index
    reset_session
    @groups = Group.all(:order => :group_name)
    @providers = Provider.all(:order => [:last_name, :first_name])
    @title = "Client Invoices"
    if params[:provider_id]
      @object = Provider.find(params[:provider_id])
      @object_list = @object.invoices.not_closed
      @provider_id = @object.id
      @group_id = nil
      @name = @object.provider_name
      @object.selector = Selector::PROVIDER
      set_provider_session @object.id, @object.provider_name
    elsif params[:group_id]
      @object = Group.find(params[:group_id])
      @object_list = @object.invoices.not_closed
      @group_id = @object.id
      @provider_id = nil
      @name = @object.group_name
      @object.selector = Selector::GROUP
      set_group_session @object.id, @object.group_name
    else
      @group_id = nil
      @provider_id = nil
      @object = nil
    end
    session[:return_to] = request.fullpath

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => {:groups =>@groups, :providers => @providers } }
    end
  end


  # GET /invoices/1
  # GET /invoices/1.json
  def show
    @invoice = Invoice.find(params[:id])
    @title = "Client Invoices"
    @object = @invoice.invoiceable_type.classify.constantize.find(@invoice.invoiceable_id)
    @object.selector = @invoice.invoiceable_type == "Provider" ? Selector::PROVIDER : Selector::GROUP
    @back_index = true
    @display_sidebar = true

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @invoice }
    end
  end


  # GET /invoices/new
  # GET /invoices/new.json
  def new
    @title = "Client Invoices"
    respond_to do |format|
      if params[:provider_id]
        @object = Provider.find(params[:provider_id])
        @name = @object.provider_name
        @object.selector = Selector::PROVIDER
        set_provider_session @object.id, @object.provider_name
      elsif params[:group_id]
        @object = Group.find(params[:group_id])
        @name = @object.group_name
        @object.selector = Selector::GROUP
        set_group_session @object.id, @object.group_name
      else
        format.html { redirect_to invoices_path, notice: "A Provider or Group must first be selected." }
      end
      @invoice = @object.invoices.new(:created_user => current_user.login_name)

      # sort the invoice_details by provider, patient, dos
      # use sort_by because this is all in memory
 #     @invoice.invoice_details.sort_by!{|x| [x.provider_name, x.patient_name, x.dos] }

      @invoice_method = InvoiceCalculation::METHODS
      @payment_terms = Invoice::PAYMENT_TERMS
      @display_sidebar = true
      @back_index = true

      format.html # new.html.erb
      format.json { render json: @invoice }
    end
  end


  # GET /invoices/1/edit
  def edit
    @title = "Client Invoices"
    @invoice = Invoice.includes(:invoice_details).find(params[:id])
    # sort the invoice_details by provider, patient, dos
    # use sort_by because this is all in memory
#    @invoice.invoice_details.sort_by!{|x| [x.provider_name, x.patient_name, x.dos] }

    @object = @invoice.invoiceable_type.classify.constantize.find(@invoice.invoiceable_id)
    @object.selector = @invoice.invoiceable_type == "Provider" ? Selector::PROVIDER : Selector::GROUP
    @invoice_method = InvoiceCalculation::METHODS
    @payment_terms = Invoice::PAYMENT_TERMS
    @display_sidebar = true
    @back_index = true

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @invoice }
    end
  end


  # POST /invoices
  # POST /invoices.json
  def create
    @invoice = Invoice.new(params[:invoice])
    @invoice.created_user = current_user.login_name
    @invoice.invoice_details.each do |i|
      i.created_user = current_user.login_name
    end
    @invoice_method = InvoiceCalculation::METHODS
    @payment_terms = Invoice::PAYMENT_TERMS
    @display_sidebar = true
    @back_index = true
    @title = "Client Invoices"
    respond_to do |format|
      if @invoice.save
        @invoice.validate
        if params[:commit] == "Update"
          format.html { render action: "new", notice: 'Invoice was successfully created.' }
        else
          format.html { redirect_to invoice_path(@invoice), notice: 'Invoice was successfully created.' }
        end
        format.json { render json: @invoice }
      else
        format.html { render action: "new" }
        format.json { render json: @invoice.errors, status: :unprocessable_entity }
      end
    end
  end


  # PUT /invoices/1
  # PUT /invoices/1.json
  def update
    @invoice = Invoice.find(params[:id])
    @invoice.updated_user = current_user.login_name
    @invoice.invoice_details.each do |i|
       i.updated_user = current_user.login_name
    end
    @object = @invoice.invoiceable_type.classify.constantize.find(@invoice.invoiceable_id)
    @object.selector = @invoice.invoiceable_type == "Provider" ? Selector::PROVIDER : Selector::GROUP
    @invoice_method = InvoiceCalculation::METHODS
    @payment_terms = Invoice::PAYMENT_TERMS
    @display_sidebar = true
    @back_index = true
    @title = "Client Invoices"
    respond_to do |format|
      if @invoice.update_attributes(params[:invoice])
        @invoice.validate
        if params[:commit] == "Update"
          format.html { render action: "new", notice: 'Invoice was successfully created.' }
        else
          format.html { redirect_to invoice_path(@invoice), notice: 'Invoice was successfully updated.' }
        end
        format.json { render json: @invoice }
      else
        format.html { render action: "edit" }
        format.json { render json: @invoice.errors, status: :unprocessable_entity }
      end
    end
  end


  # DELETE /invoices/1
  # DELETE /invoices/1.json
  def destroy
    @invoice = Invoice.find(params[:id])
    @invoice.updated_user = current_user.login_name
    @invoice.destroy

    respond_to do |format|
      format.html {
        hash = @invoice.provider? ? {:provider_id => @invoice.invoiceable_id} : {:group_id => @invoice.invoiceable_id}
        redirect_to invoices_path(hash), notice: 'Invoice was deleted.'
      }
      format.json { head :no_content }
    end
  end


  #
  # Ajax pull of the list of invoices not closed for the selected provider / group
  #
  def ajax_index
    reset_session
    if !params[:group_id].blank?
      @object = Group.find(params[:group_id])
      @object_list = @object.invoices.not_closed
      @name = @object.group_name
      @object.selector = Selector::GROUP
      set_group_session @object.id, @object.group_name
      session[:return_to] = invoices_path(:group_id => params[:group_id])
    elsif !params[:provider_id].blank?
      @object = Provider.find(params[:provider_id])
      @object_list = @object.invoices.not_closed
      @name = @object.provider_name
      @object.selector = Selector::PROVIDER
      set_provider_session @object.id, @object.provider_name
      session[:return_to] = invoices_path(:provider_id => params[:provider_id])
    end
    @title = "Client Invoices"
    @invoice_method = InvoiceCalculation::METHODS
    @display_links = true

    respond_to do |format|
      format.html {render :nothing => true}
      format.js {render :layout => false }
    end
  end
end
