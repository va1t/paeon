class InvoiceWorkflowController < ApplicationController
  # user must be logged into the system
  before_filter :authenticate_user!
  authorize_resource :class => Invoice

  #
  # builds and displays the selected invoice as a pdf
  #
  def show
    @client_invoice = ClientInvoice.new(params[:id])
    @client_invoice.build

    respond_to do |format|
      format.html{ send_data @client_invoice.render, :filename => "client_invoice.pdf", :type => "application/pdf" }
      format.pdf { send_data @client_invoice.render, :filename => "client_invoice.pdf", :type => "application/pdf" }
      format.json{ head :no_content }
    end
  end

  #
  # builds and displays the selected balance bill as a pdf
  # move the balance bill to the invoiced or later states.
  #
  def print
    @client_invoice = Invoice.find(params[:id])
    @object = @client_invoice.invoiceable_type.classify.constantize.find(@client_invoice.invoiceable_id)
    @client_invoice.mailed
    @title = "Print Group / Provider Invoice"

    respond_to do |format|
      format.html
      format.json{head :no_content }
    end

  end


  def waive
    @invoice = Invoice.find(params[:id])

    respond_to do |format|
      if @invoice.waive
        format.html{ redirect_to invoice_path(@invoice), notice: "The balance owed has been sucessfully waived."}
        format.json{ head :no_content }
      else
        format.html{ redirect_to invoice_path(@invoice), notice: "The balance owed faield to be waived."}
        format.json{ head :no_content }
      end
    end
  end


  def revert
    @invoice = Invoice.includes(:invoice_payments).find(params[:id])

    respond_to do |format|
      if @invoice.revert
        format.html{ redirect_to invoice_path(@invoice), notice: "Invoice reverted to previous version"}
        format.json{head :no_content }
      else
        format.html{ redirect_to invoice_path(@invoice), notice: "Invoice failed to reverted to previous version"}
        format.json{head :no_content }
      end
    end

  end

  def close
    @invoice = Invoice.includes(:invoice_payments).find(params[:id])

    respond_to do |format|
      if @invoice.close
        format.html{ redirect_to invoices_path, notice: "Invoice successfully closed"}
        format.json{head :no_content }
      else
        format.html{ redirect_to invoice_path(@invoice), notice: "Invoice failed to close"}
        format.json{head :no_content }
      end
    end

  end
end
