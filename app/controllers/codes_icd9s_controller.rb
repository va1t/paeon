class CodesIcd9sController < ApplicationController
  # user must be logged into the system
  before_filter :authenticate_user!
  authorize_resource

  # GET /codes_icd9s.json
  def index
    @codes_icd9s = CodesIcd9.all.without_status :deleted, :archived
    @title = "ICD-9 Codes"

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @codes_icd9s }
    end
  end

  # GET /codes_icd9s/1
  # GET /codes_icd9s/1.json
  def show
    @codes_icd9 = CodesIcd9.find(params[:id])
    @show = true
    @title = "ICD-9 Codes"

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @codes_icd9 }
    end
  end

  # GET /codes_icd9s/new
  # GET /codes_icd9s/new.json
  def new
    @codes_icd9 = CodesIcd9.new
    @newedit = true
    @title = "New ICD-9 Codes"

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @codes_icd9 }
    end
  end

  # GET /codes_icd9s/1/edit
  def edit
    @codes_icd9 = CodesIcd9.find(params[:id])
    @newedit = true
    @title = "Editing ICD-9 Codes"
  end

  # POST /codes_icd9s
  # POST /codes_icd9s.json
  def create
    @codes_icd9 = CodesIcd9.new(params[:codes_icd9])
    @codes_icd9.created_user = current_user.login_name

    respond_to do |format|
      if @codes_icd9.save
        format.html { redirect_to @codes_icd9, notice: 'Codes icd9 was successfully created.' }
        format.json { render json: @codes_icd9, status: :created, location: @codes_icd9 }
      else
        format.html { render action: "new" }
        format.json { render json: @codes_icd9.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /codes_icd9s/1
  # PUT /codes_icd9s/1.json
  def update
    @codes_icd9 = CodesIcd9.find(params[:id])
    @codes_icd9.updated_user = current_user.login_name

    respond_to do |format|
      if @codes_icd9.update_attributes(params[:codes_icd9])
        format.html { redirect_to @codes_icd9, notice: 'Codes icd9 was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @codes_icd9.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /codes_icd9s/1
  # DELETE /codes_icd9s/1.json
  def destroy
    @codes_icd9 = CodesIcd9.find(params[:id])
    @codes_icd9.updated_user = current_user.login_name
    @codes_icd9.destroy

    respond_to do |format|
      format.html { redirect_to codes_icd9s_url }
      format.json { head :no_content }
    end
  end
end
