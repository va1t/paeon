class Reports::OpenDosRptController < ApplicationController
  # user must be logged into the system
  before_filter :authenticate_user!
  authorize_resource :class => Reporting

  #
  # GET /reports/open_dos_rpt
  # GET /reports/open_dos_rpt.json
  # GET /reports/open_dos_rpt.csv
  # GET /reports/open_dos_rpt.pdf
  #
  def index

  end
end
