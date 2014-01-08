#
# The reporting table contains the list of reports available for use.
# The table is updated with a rake task csv:reports which pulls in the reports from a csv file.  
# The csv file is located in db/seeds/reports.csv. Each report is a line in the csv file.  
# When the rake task is run the entire table will be reloaded. The order of the csv file denotes to initial order 
# the reports will be displayed in the drop downs.
#

class Reporting < ActiveRecord::Base
  #
  # includes
  #
  include CommonStatus
  
  #
  # constants
  #
  
  # category constants.  Each constant matches to a boolean field in the db table
  ALL      = "All Reports"
  PROVIDER = "Providers"
  PATIENT  = "Patients"
  CLAIM    = "Claims"
  BALANCE  = "Balance Bills"
  INVOICES = "Invoices"
  USER     = "User Related"
  SYSTEM   = "System Related"
  
  CATEGORY_REPORTS = [ALL, PROVIDER, PATIENT, CLAIM, BALANCE, INVOICES, USER, SYSTEM]
  
  #
  # assignments
  #
  attr_accessible :title, :description, :name, :created_user, :updated_user,
                  :category_all, :category_provider, :category_patient, :category_claim, :category_balance,
                  :category_invoice, :category_user, :category_system 
  attr_protected  :status
  
  #
  # validations
  #
  validates :title,        :presence => true  
  validates :description,  :presence => true
  validates :name,         :presence => true
  validates :created_user, :presence => true
  
  validates :category_all,      :inclusion => {:in => [true, false]}
  validates :category_provider, :inclusion => {:in => [true, false]}
  validates :category_patient,  :inclusion => {:in => [true, false]}
  validates :category_claim,    :inclusion => {:in => [true, false]}
  validates :category_balance,  :inclusion => {:in => [true, false]}
  validates :category_invoice,  :inclusion => {:in => [true, false]}
  validates :category_user,     :inclusion => {:in => [true, false]}
  validates :category_system,   :inclusion => {:in => [true, false]}
  
  
end
