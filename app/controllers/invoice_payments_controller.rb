class InvoicePaymentsController < ApplicationController
  # user must be logged into the system
  before_filter :authenticate_user!
  authorize_resource


  def new

    @title = "Create Invoice Payment"
    @display_sidebar = true

    respond_to do |format|
      format.html  #render new
      format.json { head :no_content }
    end
  end


  def edit

    @title = "Update Invoice Payment"
    @display_sidebar = true

    respond_to do |format|
      format.html  #render edit
      format.json { head :no_content }
    end
  end


  def create

    respond_to do |format|
      if @invoice_payment.save
        @balance_bill.record_payment
        format.html { redirect_to invoice_path(@invoice), notice: "Successfully created payment for invoice."}
        format.json { render json @invoice_payment }
      else
        format.html { render "new", notice: "Failed to create the invoice payment" }
        format.json { render json: @invoice_payment.errors, status: :unprocessable_entity }
      end
    end
  end


  def update

    respond_to do |format|
      if @invoice_payment.update_attributes(params[:invoice_payment])
        @invoice.record_payment
        format.html { redirect_to balance_bill_path(@invoice), notice: "Successfully updated payment for invoice."}
        format.json { render json @invoice_payment }
      else
        format.html { render "edit", notice: "Failed to update the invoice payment" }
        format.json { render json: @invoice_payment.errors, status: :unprocessable_entity }
      end
    end

  end

end
