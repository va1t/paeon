# this controller is for applying payments to outstanding balance bills
# and flowing the balance bills through the system.
# for creating new, deleting and full editing of balance bills, the balance bills controller
# provides that functionality
#
class BalanceBillPaymentsController < ApplicationController
  # user must be logged into the system
  before_filter :authenticate_user!
  authorize_resource :class => BalanceBill

  # /GET/balance_bill_payments/new
  # /GET/balance_bill_payments/new.json
  def new
    @balance_bill = BalanceBill.includes(:balance_bill_payments, :patient).find(params[:balance_bill_id])
    @balance_bill_payments = @balance_bill.balance_bill_payments
    @patient = @balance_bill.patient
    #add a new payment on the end
    @balance_bill_payment = @balance_bill.balance_bill_payments.new
    @payment_method = BalanceBillPayment::PAYMENT_METHOD
    @title = "Create Balance Bill Payment"
    @display_sidebar = true

    respond_to do |format|
      format.html  #render new
      format.json { head :no_content }
    end
  end


  # GET /balance_bill_payments/edit
  # GET /balance_bill_payments/edit.json
  def edit
    @balance_bill = BalanceBill.includes(:balance_bill_payments, :patient).find(params[:balance_bill_id])
    @balance_bill_payments = @balance_bill.balance_bill_payments
    @patient = @balance_bill.patient
    @balance_bill_payment = BalanceBillPayment.find(params[:id])
    @payment_method = BalanceBillPayment::PAYMENT_METHOD
    @title = "Update Balance Bill Payment"
    @display_sidebar = true

    respond_to do |format|
      format.html  #render edit
      format.json { head :no_content }
    end
  end


  # POST /balance_bills/1
  # POST /balance_bills/1.json
  def create
    @balance_bill = BalanceBill.includes(:balance_bill_payments).find(params[:balance_bill_id])
    @balance_bill.updated_user = current_user.login_name
    @balance_bill_payment = @balance_bill.balance_bill_payments.new(params[:balance_bill_payment])
    @balance_bill_payment.created_user = current_user.login_name
    @payment_method = BalanceBillPayment::PAYMENT_METHOD

    respond_to do |format|
      if @balance_bill_payment.save
        @balance_bill.record_payment
        format.html { redirect_to balance_bill_path(@balance_bill), notice: "Successfully created payment for balance bill."}
        format.json { render json @balance_bill_payment }
      else
        format.html { render "new", notice: "Failed to create the balance bill payment" }
        format.json { render json: @balance_bill_payment.errors, status: :unprocessable_entity }
      end
    end
  end


  # PUT /balance_bills/1
  # PUT /balance_bills/1.json
  def update
    @balance_bill = BalanceBill.includes(:balance_bill_payments).find(params[:balance_bill_id])
    @balance_bill.updated_user = current_user.login_name
    @balance_bill_payment = BalanceBillPayment.find(params[:id])
    @balance_bill_payment.updated_user = current_user.login_name
    @payment_method = BalanceBillPayment::PAYMENT_METHOD

    respond_to do |format|
      if @balance_bill_payment.update_attributes(params[:balance_bill_payment])
        @balance_bill.record_payment
        format.html { redirect_to balance_bill_path(@balance_bill), notice: "Successfully updated payment for balance bill."}
        format.json { render json @balance_bill_payment }
      else
        format.html { render "edit", notice: "Failed to update the balance bill payment" }
        format.json { render json: @balance_bill_payment.errors, status: :unprocessable_entity }
      end
    end
  end

end
