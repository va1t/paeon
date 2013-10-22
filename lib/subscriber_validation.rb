#
#
# The patient's insurance needs to be verified for each provider
# The in-network / out-network status, number of sessions, annual limits  
# all need to be defined and verified
#
# This class provides an easy method to managing the status of the subscriber validation record
# the validation record is tied to the join table(s) between patients & providers and patient & groups
#

class SubscriberValidate
  
  NEW         = 100     # new patient or new patient insured record
  NOTVERIFIED = 200     # record was updated but not set to verified
  UPDATED     = 300     # patient insured record was changed, so this flag lets us know it may need to be re-validated
  VERIFIED    = 900     # cliet insured record has been verified with provider
  
  
  def self.status(current_status)
    case current_status
    when NEW
      str = "New Patient"
    when NOTVERIFIED
      str = "Not Verified"
    when UPDATED
      str = "Updated Insurance Record"
    when VERIFIED
      str = "Verified"      
    end
    return str
  end
  
end