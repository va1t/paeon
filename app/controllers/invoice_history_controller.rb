class InvoiceHistoryController < ApplicationController
  # user must be logged into the system
  before_filter :authenticate_user!
  authorize_resource :class => Invoice


  def index
  end

  def group
  end

  def provider
  end
end
