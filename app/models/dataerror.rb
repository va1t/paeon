#
# The dataerror table is a polmorphic table storing the errors for each of the key table fields used in claims or balance billing
# Upon saving a record, an after_save callback is triggered executing the validate_data() method
# 
# The validate_data() method checks each field within the record for certain criteria.  
# If there is an error, a corresponding error message is then saved to the dataerror table
#
# the dataerror table, because it contains error data on potentially all records, does not have a deleted flag
# when rows are destroyed, they are deleted from the table.
#
# When an insurance_billing or balance_bill record is saved, there are 2 callbacks triggered.  The first callback triggers the validate_data() method
# the second callback triggers with the validate_claim or validate_balance_bill method.  These methods look at each table relationship to see if there are any 
# errors in the supporting tables for a claim or balanc ebill to be generated.  If there are errors, the total count of the errors are stroed along with 
# the dataerrors boolean being set to true.
#
# Errors must be cleared before a claim ro balance bill can be submitted cleanly.
# The override.  There are situations where the system requires a piece of information, but a specific insurance company does not.
# the overrde function will force a claim or balance bill into the ready state for submitting.  The errors remain in the system associated to the claim or balance bill. 


class Dataerror < ActiveRecord::Base
    
  belongs_to :dataerrorable, :polymorphic => true
  
  attr_accessible :message, :dataerrorable_id, :dataerrorable_type, 
                  :created_user, :deleted,  :updated_user
  
  #
  # constants used for the "type" field
  #
  PATIENT            = "Patient"
  SUBSCRIBER         = "Subscriber"
  GROUP              = "Group"
  PROVIDER           = "Provider"
  INSURANCE_COMPANY  = "InsuranceCompany"
  OFFICE             = "Office"
  PROVIDER_INSURANCE = "ProviderInsurance"
  INSURANCE_SESSION  = "InsuranceSession"
  INSURANCE_BILLING  = "insuranceBilling"
  IPROCEDURE         = "Iprocedure"
  IDIAGNOSTICE       = "Idiagnostic"
  BALANCEBILL        = "BalanceBill"
  SYSTEM_INFO        = "SystemInfo"


  def self.store(messages)
    begin
       self.transaction do
         messages.each(&:save)
       end 
    rescue
      return false
    end       
    return true
  end
  
end
