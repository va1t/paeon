class BalanceBillHistoryController < ApplicationController
  # user must be logged into the system
  before_filter :authenticate_user!
  authorize_resource :class => BalanceBill

  # /GET/balance_bill_history
  # /GET/balance_bill_history.json
  # allows selection of provider or patient to display history
  def index
    #TODO build index screen to allow selection of provider or patient nd pull up thier history.
  end

  # /GET/balance_bill_history/:id/patient
  # /GET/balance_bill_history/:id/patient.json
  def patient
    #TODO add pagination
    @balance_bills = BalanceBill.includes(:patient, :provider, :balance_bill_payments, :balance_bill_sessions => :balance_bill_details).with_balance_status(:closed).find(:all, :conditions => {:patient_id => params[:id]}, :order => 'invoice_date DESC')
    @title = "Balance Bill History"

    respond_to do |format|
      format.html  #render patient
      format.json { head :no_content }
    end
  end

  # /GET/balance_bill_history/:id/provider
  # /GET/balance_bill_history/:id/provider.json
  def provider
    #TODO add pagination
    @balance_bills = BalanceBill.includes(:patient, :provider, :balance_bill_payments, :balance_bill_sessions => :balance_bill_details).with_balance_status(:closed).find(:all, :conditions => {:provider_id => params[:id]}, :order => 'invoice_date DESC')
    @title = "Balance Bill History"

    respond_to do |format|
      format.html  #render provider
      format.json { head :no_content }
    end
  end
end
