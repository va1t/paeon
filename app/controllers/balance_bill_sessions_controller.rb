# the balance bill related sessions are created through this controller. All balance bill session related records for a specific claim are
# displayed from the new/edit methods.  There should be only one balance bill record for a specific session at any given time.
# the specfic balance bill session record can have multiple detail records.
# If there are multiple records for balance billing, all records are displayed in the new/edit with the current one displayed in a form.

class BalanceBillSessionsController < ApplicationController
  # user must be logged into the system
  before_filter :authenticate_user!
  authorize_resource :class => BalanceBill


  #
  # GET /balance_bill_session/new
  # GET /balance_bill_session/new.json
  #
  def new
    @insurance_session = InsuranceSession.includes(:group, :provider, :patient, :insurance_billings, :notes).find(params[:insurance_session_id])
    @insurance_billings = @insurance_session.insurance_billings
    setup_session

    @balance_bill_session = @insurance_session.build_balance_bill_session(:created_user => current_user.login_name)
    @pos = CodesPos.find_by_code(@insurance_session.pos_code)
    @title = "Balance Billing"
    @display_sidebar = true

    respond_to do |format|
      format.html # new.html
      format.json { head :no_content }
    end
  end


  #
  # GET /balance_bill_session/1/edit
  # GET /balance_bill_sessions/1/edit.json
  #
  def edit
    @insurance_session = InsuranceSession.includes(:group, :provider, :patient, :insurance_billings, :notes).find(params[:insurance_session_id])
    @insurance_billings = @insurance_session.insurance_billings
    setup_session

    @balance_bill_session = BalanceBillSession.without_status(:deleted, :archived).includes(:balance_bill_details).find(params[:id])
    @pos = CodesPos.find_by_code(@insurance_session.pos_code)
    @title = "Balance Billing"
    @display_sidebar = true

    respond_to do |format|
      format.html # new.html
      format.json { head :no_content }
    end
  end


  def create
    @insurance_session = InsuranceSession.find(params[:insurance_session_id])
    @balance_bill_session = @insurance_session.build_balance_bill_session(params[:balance_bill_session])
    @balance_bill_session.created_user = current_user.login_name
    # set the insurance session status
    @balance_bill_session.insurance_session.set_status(SessionFlow::BALANCE)
    @insurance_billings = @insurance_session.insurance_billings
    @pos = CodesPos.find_by_code(@insurance_session.pos_code)
    @title = "Balance Billing"
    @display_sidebar = true

    respond_to do |format|
      if @balance_bill_session.save
        format.html {
          if params[:commit] == "Update Balance Bill"
            redirect_to edit_insurance_session_balance_bill_session_path(@insurance_session.id, @balance_bill_session.id), notice: 'Balance Bill for Session was successfully updated.'
          else
            redirect_to insurance_sessions_path, notice: 'Balance Bill for Session was successfully updated.'
          end
        }
        format.json { head :no_content }
      else
        notice = 'Error saving.'
        @balance_bill_session.errors.full_messages.each {|msg| notice += " " + msg } if @balance_bill_session.errors.any?
        format.html { render "new", notice: notice }
        format.json { render json: @balance_bill_session.errors, status: :unprocessable_entity }
      end
    end
  end


  def update
    @insurance_session = InsuranceSession.find(params[:insurance_session_id])
    @balance_bill_session = BalanceBillSession.find(params[:id])
    @balance_bill_session.updated_user = current_user.login_name
    @insurance_billings = @insurance_session.insurance_billings
    @pos = CodesPos.find_by_code(@insurance_session.pos_code)
    @title = "Balance Billing"
    @display_sidebar = true

    respond_to do |format|
      if @balance_bill_session.update_attributes(params[:balance_bill_session])
        format.html {
          if params[:commit] == "Update Balance Bill"
            redirect_to edit_insurance_session_balance_bill_session_path(@insurance_session.id, @balance_bill_session.id), notice: 'Balance Bill for Session was successfully updated.'
          else
            redirect_to insurance_sessions_path, notice: 'Balance Bill for Session was successfully updated.'
          end
        }
        format.json { head :no_content }
      else
        notice = 'Error saving.'
        @balance_bill_session.errors.full_messages.each {|msg| notice += " " + msg } if @balance_bill_session.errors.any?
        format.html { render "edit", notice: notice }
        format.json { render json: @balance_bill.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @balance_bill = BalanceBillSession.find(params[:id])
    @balance_bill.updated_user = current_user.login_name
    @balance_bill.destroy

    respond_to do |format|
      format.html { redirect_to insurance_sessions_path }
      format.json { head :no_content }
    end
  end


  #
  # GET /balance_bill/:balance_bill_id/ajax_detail
  # used in adding detail records to the balance bill
  def ajax_detail
    @insurance_session = InsuranceSession.find(params[:insurance_session_id])
    @balance_bill_session = BalanceBillSession.find(params[:balance_bill_session_id])
    #if there are added records, then make sure to include them in the returned form
    if params[:balance_bill_session]
      params[:balance_bill_session][:balance_bill_details_attributes].each do |key, value|
        # if the id value is blank then push the new record to the end
        @balance_bill_session.balance_bill_details.build(value) if value[:id].blank?
      end
    end
    @count = @balance_bill_session.balance_bill_details.count
    # add the additional new record
    @balance_bill_session.balance_bill_details.build()

    respond_to do |format|
      format.js {render :layout => false }
    end
  end


  private


  #
  # make sure the session variables are set correctly
  # balance bills are to a patient, so the group, provider and patient info should be set in the session variables
  def setup_session
    #set the session variables
    set_group_session(@insurance_session.group_id, @insurance_session.group.group_name) if !@insurance_session.group_id.blank?
    set_provider_session(@insurance_session.provider_id, @insurance_session.provider.provider_name)
    set_patient_session(@insurance_session.patient_id, @insurance_session.patient.patient_name)
    set_balance_session
    #set the return to path for using session notes
    session[:return_to] = insurance_session_balance_bill_sessions_path(@insurance_session.id)
  end

end
