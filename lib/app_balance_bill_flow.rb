#
# Balance billing flow allows for the tracking of balances
# Balance billing is associated to the insurance session record
#
# There can be multiple balance bill records for a specific session
# Patients may elect to send in payments per week/per month until the balance is zero
# When there is a balance bill record, the associated insurance session record will be BALANCE
# the insurance billing record(s) status should be CLOSED
#
# All updatng of the status flows is contained within the models using callbacks
#
# The status values are used in the following models: balance_bill, balance_bill_invoices,
# and balance_bill_sessions

class BalanceBillFlow
  
  INITIATE = 100  # balance bill has been initiated, but not sent to patient
  OVERRIDE = 175  # Errors on the balance bill to be overridden and sent to the client
  READY    = 200  # balance bill is ready to be sent to the client
  INVOICED = 300  # balance bill has been sent to the patient
  BALANCE  = 600  # balance is remaining after patient sent payment
  PAID     = 700  # balance paid in full
  ERRORS   = 800  # error state for balance bill
  CLOSED   = 900  # balance and claim reviewed and marked closed
  
  
  # status of the balance bill session records
  INCLUDE = 100  # default - include the session on the balance bill
  WAIVE   = 200  # do not include this record on the balance bill
  SKIP    = 300  # skip this balance bill session record on the balance bill, but allow it to appear on a future balance bills

  
  def self.status(current_status)
    case current_status      
    when INITIATE
      str = "Initiated"
    when OVERRIDE
      str = "Override Errors"
    when READY
      str = "Ready"      
    when INVOICED
      str = "Invoice Sent"
    when BALANCE
      str = "Balance Outstanding"
    when PAID
      str = "Paid in Full"
    when ERRORS
      str = "Errors"
    when CLOSED
      str = "Closed"
    else # assume the status is initiate if unknown
      str = "Initiate"
    end
    return str
  end
  
  
  #
  # used to determine if the claim is still in the initiate or ready state
  # if it is, then there could be errors with the claim that needs to be updated
  # in the initate and ready state, the user can change fields 
  def self.editable_state?(object)
    object.status == INITIATE  || object.status == READY || object.status == ERRORS
  end

  #
  # return true if the record is in the initiate or ready state or if the record equals errors.
  # otherwise the balance bill has been sent to the patient and cannot be deleted.
  #
  def self.record_deleteable?(object)
    return (object.status <= READY || object.status == ERRORS) 
    
  end
  
  #
  # returns true if the object is in the ready state
  #  
  def self.ready?(object)
    return object.status == READY
  end
  
  #
  # used to determine if the claim is still in the initiate state
  # if it is, then there could be errors with the claim that needs to be updated 
  def self.initial_status?(object)
    object.status == INITIATE
  end

end