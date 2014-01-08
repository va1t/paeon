class RatesController < ApplicationController
  # user must be logged into the system
  before_filter :authenticate_user!
  authorize_resource

  # GET /rates
  # GET /rates.json
  def index
    @rateable, @name = find_polymorphic
    @rates = @rateable.rates.order(:description)
    @title = @name.titleize + " Rates"

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @rates }
    end
  end

  # GET /rates/1
  # GET /rates/1.json
  def show
    @rateable, @name = find_polymorphic
    @rate = Rate.find(params[:id])
    @title = @name.titleize + " Rate"
    @show = true

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @rate }
    end
  end

  # GET /rates/new
  # GET /rates/new.json
  def new
    @rateable, @name = find_polymorphic
    @rate = Rate.new
    @title = @name.titleize + " Rate"
    @cpt_codes = CodesCpt.without_status :deleted, :archived
    @newedit = true

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @rate }
    end
  end

  # GET /rates/1/edit
  def edit
    @rateable, @name = find_polymorphic
    @rate = Rate.find(params[:id])
    @title = @name.titleize + " Rate"
    @cpt_codes = CodesCpt.without_status :deleted, :archived
    @newedit = true
  end

  # POST /rates
  # POST /rates.json
  def create
    @rateable, @name = find_polymorphic
    @rate = @rateable.rates.build(params[:rate])
    @rate.created_user = current_user.login_name

    respond_to do |format|
      if @rate.save
        format.html { redirect_to polymorphic_path([@rateable, :rates]), notice: 'Rate was successfully created.' }
        format.json { render json: @rate, status: :created, location: @rate }
      else
        format.html { render action: "new" }
        format.json { render json: @rate.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /rates/1
  # PUT /rates/1.json
  def update
    @rateable, @name = find_polymorphic
    @rate = Rate.find(params[:id])
    @rate.updated_user = current_user.login_name

    respond_to do |format|
      if @rate.update_attributes(params[:rate])
        format.html { redirect_to polymorphic_path([@rateable, :rates]), notice: 'Rate was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @rate.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rates/1
  # DELETE /rates/1.json
  def destroy
    @rateable, @name = find_polymorphic
    @rate = Rate.find(params[:id])
    @rate.destroy

    respond_to do |format|
      format.html { redirect_to polymorphic_path([@rateable, :rates]) }
      format.json { head :no_content }
    end
  end
end
