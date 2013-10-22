# maintenance controller on edi vendors.  called from the maintenance screen.

class EdiVendorsController < ApplicationController
  # user must be logged into the system
  before_filter :authenticate_user! 
  authorize_resource
  
  # GET /edi_vendors
  # GET /edi_vendors.json
  def index
    @edi_vendors = EdiVendor.all
    @title = "EDI Vendors"
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @edi_vendors }
    end
  end

  # GET /edi_vendors/1
  # GET /edi_vendors/1.json
  def show
    @edi_vendor = EdiVendor.find(params[:id])
    @show = true
    @title = "Show EDI Vendor"
    @subtitle = "EDI Vendor: #{@edi_vendor.name}"
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @edi_vendor }
    end
  end


  # GET /edi_vendors/1/edit
  def edit
    @edi_vendor = EdiVendor.find(params[:id])
    @newedit = true
    @title = "Edit EDI Vendor"
  end


  # PUT /edi_vendors/1
  # PUT /edi_vendors/1.json
  def update
    @edi_vendor = EdiVendor.find(params[:id])
    @edi_vendor.updated_user = current_user.login_name
    
    respond_to do |format|
      if @edi_vendor.update_attributes(params[:edi_vendor])
        format.html { redirect_to @edi_vendor, notice: 'Edi vendor was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @edi_vendor.errors, status: :unprocessable_entity }
      end
    end
  end
  
  
  def test_connection
    @edi_vendor = EdiVendor.find(params[:id])
    @local_send = Rails.root.join('sftp/sending')
    @local_receive = Rails.root.join('sftp/receive')
    @oa = OfficeAlly::SFTP.new(false)
    @oa.setup({:address => @edi_vendor.ftp_address, :port => @edi_vendor.ftp_port, :user_id => @edi_vendor.username, :password => @edi_vendor.password, 
               :send_to => @edi_vendor.folder_send_to, :receive_from => @edi_vendor.folder_receive_from, :local_send => @local_send, :local_remote => @local_remote})
    @status, @results = @oa.test_connection
    @show = true
    @title = "Test EDI Vendor Connection"
    @subtitle = "EDI Vendor Name: #{@edi_vendor.name}"

    respond_to do |format|
      format.html # test_connection.html.erb
      format.json { render json: @edi_vendor }
    end
    
  end
end
