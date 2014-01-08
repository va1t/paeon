class HomeController < ApplicationController
  before_filter :authenticate_user!

  #
  # main landing page for application.  Users are redirected to login when first accessing the system
  # The main menu is displayed on this screen and the session variables are all reset to nil
  #
  def index
    authorize! :manage, :home
    reset_session

    # base system stats
    @base = Hash.new
    @base[:patients]  = Patient.count
    @base[:groups]    = Group.count
    @base[:providers] = Provider.count

    # session billing stats
    @claims = Hash.new
    #ins billing claims
    # claims in the initial state do not have a stand alone view in ins billing, processing or eob controllers.
    # the view for claims in initial state will be under the home controller, since this is the only controller utilizing the view
    @claims[:initiated]     = InsuranceBilling.initial.count
    @claims[:ready]         = InsuranceBilling.pending.count
    @claims[:processed]     = InsuranceBilling.processed.count
    @claims[:agedprocessed]  = InsuranceBilling.aged_between(15.days.ago, 29.days.ago).count
    @claims[:agedprocessed2] = InsuranceBilling.aged_between(30.days.ago, 44.days.ago).count
    @claims[:agedprocessed3] = InsuranceBilling.aged_processed(45.days.ago).count
    # posted and unassigned EOBs
    @claims[:assigned]      = Eob.assigned.count
    @claims[:unassigned]    = Eob.unassigned.count

    #balance billing stats
    @balance = Hash.new
    @balance[:not_sent]     = BalanceBill.without_status(:deleted, :archived).with_balance_status(:initiated, :ready).count
    @balance[:invoiced]     = BalanceBill.without_status(:deleted, :archived).with_balance_status(:patient_invoiced).count
    @balance[:over_due]     = BalanceBill.without_status(:deleted, :archived).with_balance_status(:first_notice, :second_notice, :third_notice).count
    @balance[:collections]  = BalanceBill.without_status(:deleted, :archived).with_balance_status(:collections).count
    @balance[:partial]      = BalanceBill.without_status(:deleted, :archived).with_balance_status(:patient_invoiced, :partial_payment, :first_notice, :second_notice, :third_notice, :collections).count
    @balance[:paid]         = BalanceBill.without_status(:deleted, :archived).with_balance_status(:paid_in_full).count

    #pull the session stats
    @session = Hash.new
    @session[:primary]       = InsuranceSession.primary.count
    @session[:secondary]     = InsuranceSession.secondary.count
    @session[:tertiary]      = InsuranceSession.tertiary.count
    @session[:other]         = InsuranceSession.other.count
    @session[:balancebill]   = InsuranceSession.balancebill.count
    @session[:no_claims]     = InsuranceSession.no_claims.count
    @session[:closed_claims] = InsuranceSession.closed_claims.count

    #grab the Providers birthdays
    arr = []
    (0..13).each{|i| arr << (Date.today+i.day).yday }
    @provider_birthday = Provider.birthday(arr)
    #@patient_birthday = Patient.birthday(arr)
    @managed_care_warning = ManagedCare.includes(:patient).warning


    respond_to do |format|
      format.html # index.html.erb
    end
  end

  #
  # view a simple listing of all claims in the initial state.  Each claim will link to the
  # insurance billing controller, so the claims can be viewed individually.
  #
  def initial_billing
    authorize! :manage, :home
    @claims = InsuranceBilling.initial
    @title = "Claims in Initiated State"

    respond_to do |format|
      format.html {render :layout => "application" }# initial_billing.html.erb
    end
  end


  # GET home/initsess/:id
  # sets the session variables to the patient context then redirects to the
  # index on ins billing.  Setting the context correctly ensure ins billing functions correctly
  def session_initial_state
    authorize! :manage, :home
    @insurance_session = InsuranceSession.find(params[:id])
    set_patient_session(@insurance_session.patient_id, @insurance_session.patient.patient_name)
    respond_to do |format|
      format.html {
        if @insurance_session.status == SessionFlow::BALANCE
          redirect_to edit_insurance_session_balance_bill_session_path(@insurance_session, @insurance_session.balance_bill_session)
        else
          redirect_to insurance_session_insurance_billings_path(@insurance_session)
        end
      }
    end
  end

  #
  # GET home/initial_balance
  # displays list of all balance bills in the initial state
  def initial_balance
    authorize! :manage, :home
    @balance_bill = BalanceBill.initial
    @title = "Balance Bills in Initiated State"

    respond_to do |format|
      format.html {render :layout => "application" }# initial_balance.html.erb
    end
  end


  # GET /home/session_status/:status
  # displays the sessions in a certain status state
  #
  def session_status
    authorize! :manage, :home
    @status =  params[:status].to_i
    @title = "Sessions with Status: " + SessionFlow.status(@status)
    case @status
      when SessionFlow::PRIMARY
        @sessions = InsuranceSession.primary
      when SessionFlow::SECONDARY
        @sessions = InsuranceSession.secondary
      when SessionFlow::TERTIARY
        @sessions = InsuranceSession.tertiary
      when SessionFlow::OTHER
        @sessions = InsuranceSession.other
      when SessionFlow::BALANCE
        @sessions = InsuranceSession.balancebill
      else
        @sessions = nil
    end

    respond_to do |format|
      format.html {render :layout => "application" }
    end
  end


  #
  # GET /home/badsession/:status
  #
  def bad_session
    authorize! :manage, :home
    @status = params[:status].to_i
    case @status
      when 100   # all claims / balanced bills closed for the session
        @title = "All claims & balance bills closed for session"
        @sessions = InsuranceSession.closed_claims
      when 200   # no claims and balance bills  for the session
        @title = "No claims or balance bills for session"
        @sessions = InsuranceSession.no_claims
    end

    respond_to do |format|
      format.html {render :layout => "application" }
    end
  end

  #
  # GET /home/system_stats/:context
  # resets the session variables before redirecting to the appropriate index screen
  # this reset protects against pepole hitting the back button to get back to the home page
  # by hitting the back button, the session variables maay be set, which can cause an issue
  def system_stats
    authorize! :manage, :home
    reset_session
    respond_to do |format|
      case params[:context].to_i
        when Selector::GROUP
          format.html {redirect_to groups_path}
        when Selector::PROVIDER
          format.html {redirect_to providers_path}
        when Selector::PATIENT
          format.html {redirect_to patients_path}
      end
    end
  end
end
