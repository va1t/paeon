class OfficesController < ApplicationController
  # user must be logged into the system
  before_filter :authenticate_user!
  authorize_resource

  # GET /offices
  # GET /offices.json
  def index
    @officeable, @name = find_polymorphic
    @offices = @officeable.offices
    @title = @name.titleize + " Offices"

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @offices }
    end
  end


  # GET /offices/1
  # GET /offices/1.json
  def show
    @officeable, @name = find_polymorphic
    @office = Office.find(params[:id])
    @title = @name.titleize + " Office"
    @show = true

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @office }
    end
  end


  # GET /offices/new
  # GET /offices/new.json
  def new
    @officeable, @name = find_polymorphic
    @office = Office.new
    @title = @name.titleize + " Office"
    @priority = OfficeType.all
    @pos = CodesPos.without_status :deleted, :archived
    @newedit = true

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @office }
    end
  end


  # GET /offices/1/edit
  def edit
    @officeable, @name = find_polymorphic
    @office = Office.find(params[:id])
    @title = @name.titleize + " Offices"
    @priority = OfficeType.all
    @pos = CodesPos.without_status :deleted, :archived
    @newedit = true
  end


  # POST /offices
  # POST /offices.json
  def create
    @officeable, @name = find_polymorphic
    @office = @officeable.offices.build(params[:office])
    @office.created_user = current_user.login_name
    @priority = OfficeType.all
    @pos = CodesPos.without_status :deleted, :archived

    respond_to do |format|
      if @office.save
        format.html { redirect_to polymorphic_path([@officeable, :offices]), notice: 'Office was successfully created.' }
        format.json { render json: @office, status: :created, location: @office }
      else
        format.html { render action: "new" }
        format.json { render json: @office.errors, status: :unprocessable_entity }
      end
    end
  end


  # PUT /offices/1
  # PUT /offices/1.json
  def update
    @officeable, @name = find_polymorphic
    @office = Office.find(params[:id])
    @office.updated_user = current_user.login_name
    @priority = OfficeType.all
    @pos = CodesPos.without_status :deleted, :archived

    respond_to do |format|
      if @office.update_attributes(params[:office])
        format.html { redirect_back_or_default polymorphic_path([@officeable, :offices]), notice: 'Office was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @office.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /offices/1
  # DELETE /offices/1.json
  def destroy
    @officeable, @name = find_polymorphic
    @office = Office.find(params[:id])
    @office.destroy

    respond_to do |format|
      format.html { redirect_to polymorphic_path([@officeable, :offices]) }
      format.json { head :no_content }
    end
  end
end
