class CodesCptsController < ApplicationController
  # user must be logged into the system
  before_filter :authenticate_user!
  authorize_resource

  # GET /codes_cpts
  # GET /codes_cpts.json
  def index
    @codes_cpts = CodesCpt.all(:order => :code).without_status :deleted, :archived
    @title = "CPT Codes"

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @codes_cpts }
    end
  end

  # GET /codes_cpts/1
  # GET /codes_cpts/1.json
  def show
    @codes_cpt = CodesCpt.find(params[:id])
    @show = true
    @title = "CPT Codes"

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @codes_cpt }
    end
  end

  # GET /codes_cpts/new
  # GET /codes_cpts/new.json
  def new
    @codes_cpt = CodesCpt.new
    @title = "New CPT Code"

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @codes_cpt }
    end
  end

  # GET /codes_cpts/1/edit
  def edit
    @codes_cpt = CodesCpt.find(params[:id])
    @title = "Edit CPT Code"
  end

  # POST /codes_cpts
  # POST /codes_cpts.json
  def create
    @codes_cpt = CodesCpt.new(params[:codes_cpt])
    @codes_cpt.created_user = current_user.login_name

    respond_to do |format|
      if @codes_cpt.save
        format.html { redirect_to @codes_cpt, notice: 'Codes cpt was successfully created.' }
        format.json { render json: @codes_cpt, status: :created, location: @codes_cpt }
      else
        format.html { render action: "new" }
        format.json { render json: @codes_cpt.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /codes_cpts/1
  # PUT /codes_cpts/1.json
  def update
    @codes_cpt = CodesCpt.find(params[:id])
    @codes_cpt.updated_user = current_user.login_name

    respond_to do |format|
      if @codes_cpt.update_attributes(params[:codes_cpt])
        format.html { redirect_to @codes_cpt, notice: 'Codes cpt was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @codes_cpt.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /codes_cpts/1
  # DELETE /codes_cpts/1.json
  def destroy
    @codes_cpt = CodesCpt.find(params[:id])
    @codes_cpt.destroy

    respond_to do |format|
      format.html { redirect_to codes_cpts_url }
      format.json { head :no_content }
    end
  end
end
