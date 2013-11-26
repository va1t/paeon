class BalanceBillWorkflowController < ApplicationController
  # user must be logged into the system
  before_filter :authenticate_user!
  authorize_resource :class => BalanceBill

  #
  # builds and displays the selected balance bill as a pdf
  #
  def show
    @balance_bill = BalanceBillInvoice.new(params[:id])
    @balance_bill.build

    respond_to do |format|
      format.html{ send_data @balance_bill.render, :filename => "balance_bill.pdf", :type => "application/pdf" }
      format.pdf { send_data @balance_bill.render, :filename => "balance_bill.pdf", :type => "application/pdf" }
      format.json{ head :no_content }
    end
  end

  #
  # builds and displays the selected balance bill as a pdf
  # move the balance bill to the invoiced or later states.
  #
  def print
    @balance_bill = BalanceBill.includes(:patient, :provider).find(params[:id])
    @balance_bill.mailed
    @title = "Print Balance Bill"

    respond_to do |format|
      format.html
      format.json{head :no_content }
    end
  end


  def waive
    @balance_bill = BalanceBill.find(params[:id])

    respond_to do |format|
      if @balance_bill.waive
        format.html{ redirect_to balance_bill_path(@balance_bill), notice: "The balance owed has been sucessfully waived."}
        format.json{ head :no_content }
      else
        format.html{ redirect_to balance_bill_path(@balance_bill), notice: "The balance owed faield to be waived."}
        format.json{ head :no_content }
      end
    end
  end


  def revert
    @balance_bill = BalanceBill.includes(:balance_bill_payments).find(params[:id])

    respond_to do |format|
      if @balance_bill.revert
        format.html{ redirect_to balance_bill_path(@balance_bill), notice: "Balance Bill reverted to previous version"}
        format.json{head :no_content }
      else
        format.html{ redirect_to balance_bill_path(@balance_bill), notice: "Balance Bill failed to reverted to previous version"}
        format.json{head :no_content }
      end
    end

  end


  def close
    @balance_bill = BalanceBill.includes(:balance_bill_payments).find(params[:id])

    respond_to do |format|
      if @balance_bill.close
        format.html{ redirect_to balance_bills_path, notice: "Balance Bill successfully closed"}
        format.json{head :no_content }
      else
        format.html{ redirect_to balance_bill_path(@balance_bill), notice: "Balance Bill failed to close"}
        format.json{head :no_content }
      end
    end
  end

end
