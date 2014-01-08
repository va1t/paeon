class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_cache_buster

  helper_method :back_or_default_path

  #
  # On authorization failure direct the user to the home page. display the exception message
  #
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  #
  # prevent caching of pages.  Whe selecting back button, the data needs to be refreshed for the user.
  #
  def set_cache_buster
    response.headers["Cache-Control"] = "no-cache, no-store, must-revalidate, max-age=0"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

  #
  # redirect the user back to the session[:return_to] link
  # or to the default link
  def redirect_back_or_default(default, options = {})
    redirect_to session[:return_to] || default, :notice => options[:notice]
    session[:return_to] = nil
  end

  def back_or_default_path(default)
    # if session return_to set then send back the link
    return session[:return_to] if session[:return_to]
    # else send back the default link provided
    return default
  end

  def reset_session
    session[:context]         = nil
    session[:subcontext]      = nil
    session[:group]           = nil
    session[:group_name]      = nil
    session[:provider]        = nil
    session[:provider_name]   = nil
    session[:patient]         = nil
    session[:patient_name]    = nil
    session[:session]         = nil
    session[:return_to]       = nil
  end

  def set_group_session(id = nil, name = nil)
    session[:context]         = GROUP
    session[:group]           = id
    session[:group_name]      = name
    session[:provider]        = nil
    session[:provider_name]   = nil
    session[:patient]         = nil
    session[:patient_name]    = nil
    session[:session]         = nil
  end

  def set_provider_session(id = nil, name = nil)
    if session[:context] == nil
      session[:context]       = PROVIDER
    end
    session[:provider]        = id
    session[:provider_name]   = name
    session[:patient]         = nil
    session[:patient_name]    = nil
    session[:session]         = nil
  end

  def set_patient_session(id = nil, name = nil)
    if session[:context] == nil
      session[:context]       = PATIENT
    end
    session[:patient]         = id
    session[:patient_name]    = name
    session[:session]         = nil
  end

  def set_session_session(id = nil)
    if session[:context] == nil
      session[:context]       = SESSION
      session[:subcontext]    = SESSION
    end
    session[:session]         = id
  end

  def set_billing_session(id = nil)
    if session[:context] == nil
      session[:context]       = BILLING
      session[:subcontext]    = BILLING
    end
  end

  def set_balance_session(id = nil)
    if session[:context] == nil
      session[:context]       = BALANCE
      session[:subcontext]    = BALANCE
    end
  end

  def set_batch_session(id = nil)
    if session[:context] == nil
      session[:context]       = REPORTS
    end
  end

  def set_eob_session(id = nil)
    if session[:context] == nil
      session[:context] = EOB
    end
  end

  #
  # returns the record identified for the class passd in the params list
  # for nested routes, push the nested classes into an array. the last element in the array is
  # the last nested class called.  Pop the last class off the arry and classify it.
  #
  def find_polymorphic
    #array for nested routes / classes
    polyarry = []
    params.each do |name, value|
      if name =~ /(.+)_id$/
        n = name.dup
        n.slice!("_id")
        # push the global variable matching, the value and the name capitilized
        polyarry.push [$1, value, n.capitalize]
      end
    end
    if polyarry.blank?
      # if blank, then something is wrong with the call
      return nil
    else
      # grab the last element to return
      value = polyarry.last
      # classify the matching global variable and pull the value from the database.  Also return the name of the class.
      return value[0].classify.constantize.find(value[1]), value[2]
    end
  end


end
