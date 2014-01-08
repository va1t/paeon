#
# The reporting controller is the main interface to the system reports.
# Initially the category, title drop downs will appear.  The description is loaded when a report is selected.
# selection of a report also loads the associated form for that report.

# each report contains a namespace controller and view located in the apps/views/reports directory.
# each report view contains the index.html.rb and _form.html.rb file.  The form file is the filter selection for the specific report
# the form submits to tne reports namespace controller in apps/controllers/reports.  Each report controller contains the single method index
# for quering the database using the selection criteria.
#
# Depending upon the request either an html, csv, or pdf will be returned.
# the reports namepsace view index.html.rb contains the view of the selected data.
# the csv file is created utilizing rails csv utility
# the pdf is generated using the defined pdf template located in apps/reports/reports
#

class ReportingController < ApplicationController
  # user must be logged into the system
  before_filter :authenticate_user!
  authorize_resource

  #
  # GET /reporting
  # GET /reporting.json
  #
  # displays the initial dropdowns for user selection
  # the form area is updated with ajax calls as the user makes selections
  def index
    @reporting = Reporting.without_status(:deleted).all
    @category = Reporting::CATEGORY_REPORTS

    puts @reporting.inspect
    puts @category.inspect

    respond_to do |format|
      format.html
      format.json { render json: @reporting }
    end
  end


  #
  # updates the dropdown reports box with the current list of reports belonging to the category
  # the report form area is also blanked out until a new report is selected
  #
  def ajax_category
    case params[:category]
      when Reporting::ALL
        @query_hash = {:category_all => true}
      when Reporting::PROVIDER
        @query_hash = {:category_provider => true}
      when Reporting::PATIENT
        @query_hash = {:category_patient => true}
      when Reporting::CLAIM
        @query_hash = {:category_claim => true}
      when Reporting::BALANCE
        @query_hash = {:category_balance => true}
      when Reporting::INVOICES
        @query_hash = {:category_invoice => true}
      when Reporting::USER
        @query_hash = {:category_user => true}
      when Reporting::SYSTEM
        @query_hash = {:category_system => true}
    end
    @reporting = Reporting.without_status(:deleted).where(@query_hash)
  end

  #
  # Based on the selected report the associated form is pulled in and displayed
  # The report description is updated with the seelcted report,
  # the report form area is displayed with the selected report's form.
  def ajax_report
    @report = Reporting.find(params[:id])

  end
end
