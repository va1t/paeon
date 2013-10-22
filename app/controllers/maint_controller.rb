class MaintController < ApplicationController
  # user must be logged into the system
  before_filter :authenticate_user!  
  
  
  def index
    authorize! :manage, :maint
    reset_session
  end
  
  def notyet
    @show = true
  end
end
