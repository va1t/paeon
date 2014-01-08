class IdiagnosticsController < ApplicationController
  # user must be logged into the system
  before_filter :authenticate_user!
  authorize_resource

  # GET /idiagnostics
  # GET /idiagnostics.json
  def index
    @diagnosticable, @name = find_polymorphic
    @idiagnostics = @diagnosticable.idiagnostics
    @title = @name + " Diagnostic Codes"

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @idiagnostics }
    end
  end

  # GET /idiagnostics/1
  # GET /idiagnostics/1.json
  def show
    @diagnosticable, @name = find_polymorphic
    @idiagnostic = Idiagnostic.find(params[:id])
    @title = @name + " Diagnostic Codes"
    @show = true

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @idiagnostic }
    end
  end

  # GET /idiagnostics/new
  # GET /idiagnostics/new.json
  def new
    @diagnosticable, @name = find_polymorphic
    @idiagnostic = Idiagnostic.new
    @title = @name + " Diagnostic Codes"

    @icd9_codes = CodesIcd9.without_status :deleted, :archived
    @dsm_codes = CodesDsm.dsm.without_status :deleted, :archived
    @dsm4_codes = CodesDsm.dsm4.without_status :deleted, :archived
    @dsm5_codes = CodesDsm.dsm5.without_status :deleted, :archived

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @idiagnostic }
    end
  end

  # GET /idiagnostics/1/edit
  def edit
    @diagnosticable, @name = find_polymorphic
    @idiagnostic = Idiagnostic.find(params[:id])
    @title = @name + " Diagnostic Codes"
    @edit = true
  end

  # POST /idiagnostics
  # POST /idiagnostics.json
  def create
    @diagnosticable, @name = find_polymorphic
    @idiagnostic = @diagnosticable.idiagnostics.build(params[:idiagnostic])
    @idiagnostic.created_user = current_user.login_name

    respond_to do |format|
      if @idiagnostic.save
        format.html {
          if params[:patients_provider_id] || params[:patients_group_id]
            redirect_to_patient
          else
            redirect_to polymorphic_path(@diagnosticable), notice: 'Diagnostic code was successfully created.'
          end
        }
        format.json { render json: @idiagnostic, status: :created, location: @idiagnostic }
      else
        if @idiagnostic.errors.any?
          @msg = ""
          @idiagnostic.errors.full_messages.each do |msg|
            @msg += msg
          end
        end
        format.html { redirect_to polymorphic_path(@diagnosticable), notice: @msg}
        format.json { render json: @idiagnostic.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /idiagnostics/1
  # PUT /idiagnostics/1.json
  def update
    @diagnosticable, @name = find_polymorphic
    @idiagnostic = Idiagnostic.find(params[:id])
    @idiagnostic.updated_user = current_user.login_name

    respond_to do |format|
      if @idiagnostic.update_attributes(params[:idiagnostic])
        format.html { redirect_to polymorphic_path(@diagnosticable), notice: 'Diagnostic code was successfully updated.' }
        format.json { head :no_content }
      else
        if @idiagnostic.errors.any?
          @msg = ""
          @idiagnostic.errors.full_messages.each do |msg|
            @msg += msg
          end
        end
        format.html { redirect_to polymorphic_path(@diagnosticable), notice: @msg }
        format.json { render json: @idiagnostic.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /idiagnostics/1
  # DELETE /idiagnostics/1.json
  def destroy
    @diagnosticable, @name = find_polymorphic
    @idiagnostic = Idiagnostic.find(params[:id])
    @idiagnostic.destroy

    respond_to do |format|
      format.html { redirect_to polymorphic_path(@diagnosticable) }
      format.json { head :no_content }
    end
  end


  private

  def redirect_to_patient
    if params[:patients_provider_id]
      @jointable = PatientsProvider.find(params[:patients_provider_id])
    else
      @jointable = PatientsGroup.find(params[:patients_group_id])
    end
    redirect_to patient_path(@jointable.patient_id)
  end

end
