class IproceduresController < ApplicationController
  # user must be logged into the system
  before_filter :authenticate_user!
  authorize_resource

  # GET /iprocedures
  # GET /iprocedures.json
  def index
    @procable, @name = find_polymorphic
    @procs = @procable.iprocedures
    @title = @name + " Procedure Codes"

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @procs }
    end
  end

  # GET /iprocedures/1
  # GET /iprocedures/1.json
  def show
    @procable, @name = find_polymorphic
    @proc = Iprocedure.find(params[:id])
    @title = @name  + " Procedure Codes"
    @show = true

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @proc }
    end
  end


  # GET /iprocedures/new
  # GET /iprocedures/new.json
  def new
    @procable, @name = find_polymorphic
    @proc = Iprocedure.new
    @cpt_codes = CodesCpt.without_status :deleted, :archived
    @modifiers = CodesModifier.without_status :deleted, :archived
    @title = @name  + " Procedure Codes"
    @newedit = true

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @proc }
    end
  end


  # GET /iprocedures/1/edit
  def edit
    @procable, @name = find_polymorphic
    @proc = Iprocedure.find(params[:id])
    @cpt_codes = CodesCpt.without_status :deleted, :archived
    @modifiers = CodesModifier.without_status :deleted, :archived
    @title = @name + " Procedure Codes"
    @newedit = true
    @edit = true
  end


  # POST /iprocedures
  # POST /iprocedures.json
  def create
    @procable, @name = find_polymorphic
    @proc = @procable.iprocedures.build(params[:iprocedure])
    @proc.created_user = current_user.login_name

    respond_to do |format|
      if @proc.save
        format.html { redirect_to polymorphic_path(@procable), notice: 'Procedure Code was successfully created.' }
        format.json { render json: @proc, status: :created, location: @proc }
      else
        if @proc.errors.any?
          @msg = ""
          @proc.errors.full_messages.each do |msg|
            @msg += msg
          end
        end
        format.html { redirect_to polymorphic_path(@procable), notice: @msg }
        format.json { render json: @proc.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /iprocedures/1
  # PUT /iprocedures/1.json
  def update
    @procable, @name = find_polymorphic
    @proc = Iprocedure.find(params[:id])
    @proc.updated_user = current_user.login_name

    respond_to do |format|
      if @proc.update_attributes(params[:iprocedure])
        format.html { redirect_to polymorphic_path(@procable), notice: 'Procedure Code was successfully updated.' }
        format.json { head :no_content }
      else
        if @proc.errors.any?
          @msg = ""
          @proc.errors.full_messages.each do |msg|
            @msg += msg
          end
        end
        format.html { redirect_to polymorphic_path(@procable), notice: @msg }
        format.json { render json: @proc.errors, status: :unprocessable_entity }
      end
    end
  end


  # DELETE /iprocedures/1
  # DELETE /iprocedures/1.json
  def destroy
    @procable, @name = find_polymorphic
    @proc = Iprocedure.find(params[:id])
    @proc.destroy
    # if coming from insurance session, then we need to clena up the managed care records to keep usage numbers accurate
    if @name == "Insurance_session"
      @proc.update_managed_care(params[:insurance_session_id])
    end

    respond_to do |format|
      format.html {
        #quick fix until better solution can be found for procable and nested controllers
        if params[:insurance_session_id]
          redirect_to insurance_session_insurance_billings_path(params[:insurance_session_id])
        else
          redirect_to polymorphic_path(@procable)
        end
      }
      format.json { head :no_content }
    end
  end

end
