#
#  The billingflow class contains the constants and the status message for the claim workflow
#  this workflow is at a claim level and manages the claim from inception(INITIATE) until it is closed.
#
# All updatng of the status flows is contained within the models using callbacks
# 

class BillingFlow
  
  # billingflow constants, made it part of a class so it is clear that the constants are workflow related.
  
  # insurance billing status
  INITIATE        = 100     # initial state for a claim
  OVERRIDE        = 175     # claim has errors, but the users has elected to override the claim; This status is used in the ins_billing_history to capture everytime the claim is overridden
  READY           = 200     # claim is ready for submitting to payor for processing
  SUBMITTED       = 300     # claim submitted to payor via edi transmission 
  PRINTED         = 400     # claim submitted to payor via paper
  ACKNOWLEDGED    = 500     # claim received a 999 and/or 277 with no errors
  ACK999          = 525     # claim received a 999 acknowledgment  
  ACK277          = 550     # claim received a 277 acknowledgment
  ERRORS          = 600     # claim manually set to errors  
  ERR999          = 650     # claim received 999 errors / reject
  ERR277          = 675     # claim received 277 error / reject  
  PAID            = 700     # claim received an eob either via edi or manually entered  
  CLOSED          = 900     # claim closed; either balance billed, balance zeroed or secondary claim submitted
  CLOSED_RESUBMIT = 925     # closing the claim so it can be resubmitted with corrections
  
  # edi transaction status
  EDI_INITIATE  = 100   # edit transaction was created
  EDI_ACCEPTED  = 200   # edi transaction was accepted
  EDI_WARNINGS  = 300   # edi transaction was accepted with errors
  EDI_REJECTED  = 400   # edi transaction was rejected
  
  # edi transaction description
  EDI_837   = "837"
  EDI_999   = "999"
  EDI_276   = "276"
  EDI_277   = "277"
  EDI_835   = "835"
  
  
  def self.status(current_status)
    case current_status
    when READY
      str = "Ready"
    when SUBMITTED
      str = "Submitted"
    when PRINTED
      str = "Printed"
    when ACKNOWLEDGED, ACK999, ACK277
      str = "Acknowledged"
    when ERRORS, ERR999, ERR277
      str = "Errors"
    when PAID
      str = "Paid"
    when CLOSED
      str = "Closed"
    when CLOSED_RESUBMIT
      str = "Closed for Resubmission"
    when OVERRIDE
      str = "Claim Override"
    else #assume when the status is unknown, default to INITIATE
      str = "Initiated"
    end
    return str
  end


  #
  # used to determine if the claim is still in the initiate or ready state
  # if it is, then there could be errors with the claim that needs to be updated
  # in the initate and ready state, the user can change fields 
  def self.editable_state?(status)
    status <= READY || (status >= ERRORS && status < PAID )
  end


  #
  # used to determine if the associated record is editable according to the billing flow rules
  #
  def self.verify_record_deletable(status)
    return status > READY ? false : true    
  end

    
end

