class CodesPosController < ApplicationController
  # user must be logged into the system
  before_filter :authenticate_user!
  authorize_resource

  # GET /codes_pos
  # GET /codes_pos.json
  def index
    @codes_pos = CodesPos.without_status :deleted, :archived
    @title = "Place of Service Codes"

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @codes_pos }
    end
  end

  # GET /codes_pos/1
  # GET /codes_pos/1.json
  def show
    @codes_po = CodesPos.find(params[:id])
    @show = true
    @title = "Place of Servce Codes"

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @codes_po }
    end
  end

  # GET /codes_pos/new
  # GET /codes_pos/new.json
  def new
    @codes_po = CodesPos.new
    @newedit = true
    @title = "New Place of Service Codes"

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @codes_po }
    end
  end

  # GET /codes_pos/1/edit
  def edit
    @codes_po = CodesPos.find(params[:id])
    @newedit = true
    @title = "Editing Place of Service Codes"
  end

  # POST /codes_pos
  # POST /codes_pos.json
  def create
    @codes_po = CodesPos.new(params[:codes_po])
    @codes_po.created_user = current_user.login_name

    respond_to do |format|
      if @codes_po.save
        format.html { redirect_to @codes_po, notice: 'POS Codes were successfully created.' }
        format.json { render json: @codes_po, status: :created, location: @codes_po }
      else
        format.html { render action: "new" }
        format.json { render json: @codes_po.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /codes_pos/1
  # PUT /codes_pos/1.json
  def update
    @codes_po = CodesPos.find(params[:id])
    @codes_po.updated_user = current_user.login_name

    respond_to do |format|
      if @codes_po.update_attributes(params[:codes_po])
        format.html { redirect_to @codes_po, notice: 'POS Codes were successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @codes_po.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /codes_pos/1
  # DELETE /codes_pos/1.json
  def destroy
    @codes_po = CodesPos.find(params[:id])
    @codes_po.updated_user = current_user.login_name
    @codes_po.destroy

    respond_to do |format|
      format.html { redirect_to codes_pos_index_url }
      format.json { head :no_content }
    end
  end
end
