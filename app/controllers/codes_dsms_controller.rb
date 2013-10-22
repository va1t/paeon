class CodesDsmsController < ApplicationController
  # user must be logged into the system
  before_filter :authenticate_user! 
  authorize_resource
  
  # GET /codes_dsms
  # GET /codes_dsms.json
  def index
    if params[:type]==CodesDsm::DSM_TABLES[1]
      #show dsm iv table
      @codes_dsms = CodesDsm.dsm4
      @name = CodesDsm::DSM_TABLES[1]
      
    elsif params[:type]==CodesDsm::DSM_TABLES[2]
      # show dsm v table
      @codes_dsms = CodesDsm.dsm5
      @name = CodesDsm::DSM_TABLES[2]
    else
      #default show the dsm table
      @codes_dsms = CodesDsm.dsm
      @name = CodesDsm::DSM_TABLES[0]
    end
    @dsm_selector = CodesDsm::DSM_TABLES
    @title = "#{@name} Codes"
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @codes_dsms }
    end
  end


  # GET /codes_dsms/1
  # GET /codes_dsms/1.json
  def show
    @codes_dsm = CodesDsm.find(params[:id])
    @show = true    
    @title = @codes_dsm.version
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @codes_dsm }
    end
  end


  # GET /codes_dsms/new
  # GET /codes_dsms/new.json
  def new
    @codes_dsm = CodesDsm.new
    if params[:type]==CodesDsm::DSM_TABLES[1]
      #show dsm iv table
      @codes_dsm.version = CodesDsm::DSM_TABLES[1]
    elsif params[:type]==CodesDsm::DSM_TABLES[2]
      # show dsm v table      
      @codes_dsm.version = CodesDsm::DSM_TABLES[2]
    else
      #default show the dsm table     
      @codes_dsm.version = CodesDsm::DSM_TABLES[0]
    end            
    @newedit = true
    @title = "#{@codes_dsm.version} Codes"

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @codes_dsm }
    end
  end


  # GET /codes_dsms/1/edit
  def edit
    @codes_dsm = CodesDsm.find(params[:id])
    @title = "Editing #{@codes_dsm.version} Code"
    @newedit = true
  end


  # POST /codes_dsms
  # POST /codes_dsms.json
  def create
    @codes_dsm = CodesDsm.new(params[:codes_dsm])
    @codes_dsm.created_user = current_user.login_name
    
    respond_to do |format|
      if @codes_dsm.save
        format.html { redirect_to @codes_dsm, notice: 'Codes dsm was successfully created.' }
        format.json { render json: @codes_dsm, status: :created, location: @codes_dsm }
      else
        format.html { render action: "new" }
        format.json { render json: @codes_dsm.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /codes_dsms/1
  # PUT /codes_dsms/1.json
  def update
    @codes_dsm = CodesDsm.find(params[:id])
    @codes_dsm.updated_user = current_user.login_name
    
    respond_to do |format|
      if @codes_dsm.update_attributes(params[:codes_dsm])
        format.html { redirect_to @codes_dsm, notice: 'Codes dsm was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @codes_dsm.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /codes_dsms/1
  # DELETE /codes_dsms/1.json
  def destroy
    @codes_dsm = CodesDsm.find(params[:id])
    @codes_dsm.destroy

    respond_to do |format|
      format.html { redirect_to codes_dsms_url }
      format.json { head :no_content }
    end
  end
end
