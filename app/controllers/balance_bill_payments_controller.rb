# this controller is for applying payments to outstanding balance bills
# and flowing the balance bills through the system.
# for creating new, deleting and full editing of balance bills, the balance bills controller 
# provides that functionality
#
class BalanceBillPaymentsController < ApplicationController
  # user must be logged into the system
  before_filter :authenticate_user!    
  authorize_resource :class => BalanceBill
  
  # GET /balance_bills_receive/new
  # The session should be in an non-closed state
  # To create a 2nd or 3rd balance bill, need to make sure the balance bills are closed
  # Need to make sure there is a balance owed in teh session record
  # then redirect to new balance bill.
  def new    
    @insurance_session = InsuranceSession.find(params[:insurance_session_id])
    @balance_bills = @insurance_session.balance_bills.all
    # close all balance bills
    @balance_bills.each do |bill|
      bill.update_column(:status, BalanceBillFlow::CLOSED)
    end
    
    respond_to do |format|
    # check to make sure balance owed in sessions is greater than 0
      if @insurance_session.balance_owed > 0
        # redirect to balance_bills/new
        format.html { redirect_to new_insurance_session_balance_bill_session_path(@insurance_session) }
      elsif @insurance_session.balance_owed == 0
        # somehow the balance owed is zero and didnt get closed
        # so we will close the session and redirect back to balance_bills / submitted screen
        if @insurance_session.update_attributes(:status => SessionFlow::CLOSED)
          format.html { redirect_to processing_balance_submitted_path, notice: "Balance owed is zero, session and balance bills have been closed." }
        else
          msg = ""
          @insurance_session.errors.full_messages.each {|m| msg += m }
          format.html {  redirect_to processing_balance_submitted_path, notice: msg }
        end
      else
        # there is an error; balance owed is negative
        msg = "The session has a negative balance. You need to waive the balance in order to close the balance bill and session"
        format.html {  redirect_to processing_balance_submitted_path, notice: msg }
      end        
    end    
  end


  # GET /balance_bills_receive/:id/edit
  # the form specifically limits the editable fields to the payment received and payment date
  # This is for receiving payments only
  def edit
    @insurance_session = InsuranceSession.find(params[:insurance_session_id])
    @insurance_billings = @insurance_session.insurance_billings
    setup_session
    @balance_bills = @insurance_session.balance_bills.all
    @pos = CodesPos.find_by_code(@insurance_session.pos_code)
    @title = "Balance Bill Payment Received"
    
    respond_to do |format|
      format.html 
      format.json { head :no_content }
    end    
  end


  # PUT /balance_bills_receive/:id
  # very similar to the update method, however result back displays different actions to move the balance bill throughthe workflow
  def update    
    @insurance_session = InsuranceSession.find(params[:insurance_session_id])
    @insurance_billings = @insurance_session.insurance_billings
    setup_session
    @balance_bill = BalanceBill.find(params[:id])
    @balance_bill.updated_user = current_user.login_name    
    @pos = CodesPos.find_by_code(@insurance_session.pos_code)
    @title = "Balance Bill Payment Received"    
    
    respond_to do |format|
      if @balance_bill.update_attributes(params[:balance_bill])
        format.html { 
          if @balance_bill.insurance_session.status == SessionFlow::CLOSED
            redirect_to processing_balance_submitted_path, :format => :html, notice: "Balance Bill and Session were successfully closed"
          end
          # session was not closed, so go back to the receive payment screen with the actions buttons
          @balance_bills = @insurance_session.balance_bills.all
          render :edit
        }
        format.json { head :no_content }
      else
        notice = 'Error saving.'
        @balance_bill.errors.full_messages.each {|msg| notice += " " + msg } if @balance_bill.errors.any?
        format.html { redirect_to insurance_session_balance_bills_path, notice: notice }
        format.json { render json: @balance_bill.errors, status: :unprocessable_entity }
      end
    end
    
  end


  # GET /balance_bills_receive/waive
  # We have received a payment and want to waive any remaining fees.
  # close all balance bills, zero out the balance owed and move into the waived fee in the session record
  # Redirect the user back to the submited balance bills screen
  def waive
    @insurance_session = InsuranceSession.find(params[:insurance_session_id])
    @insurance_billings = @insurance_session.insurance_billings
    @balance_bills = @insurance_session.balance_bills.all

    # loop through all balance bills and make sure they are closed
    @balance_bills.each do |bill|
      bill.update_column(:status, BalanceBillFlow::CLOSED)
    end
    
    respond_to do |format|
      # update the balance owed and waived fee in session and close the session
      if @insurance_session.update_attributes(:status => SessionFlow::CLOSED, :balance_owed => 0, :waived_fee => @insurance_session.balance_owed)
        # redirect the use back to the processing / balance bills submitted screen
        format.html { redirect_to processing_balance_submitted_path, notice: "Balance has been waived and session has been closed." }
      else
        # redirect back to the edit payment screen with error message
        @pos = CodesPos.find_by_code(@insurance_session.pos_code)
        msg = ""
        @insurance_session.errors.full_messages.each {|m| msg += m}
        render :edit, notice: msg
      end
    end
  end
  
  
  private
    
  #
  # make sure the session variables are set correctly
  # balance bills are to a patient, so the group, provider an dpatient info should be set in the session variables
  def setup_session
    #set the session variables 
    set_group_session(@insurance_session.group_id, @insurance_session.group.group_name) if !@insurance_session.group_id.blank?
    set_provider_session(@insurance_session.provider_id, @insurance_session.provider.provider_name)
    set_patient_session(@insurance_session.patient_id, @insurance_session.patient.patient_name)
    set_balance_session
  end
  
end
