#
#  The sessionflow class contians the constants used for the session status
#  this class manages the flow of the session unitl all claims are paid and 
#  the balance for the session is zeroed out.
#
#  Session balances can be zeroed out by all claims being paid, fees waived or balance billing,
#  or a combination of all three
#
# All updatng of the status flows is contained within the models using callbacks
#

class SessionFlow
  
  OPEN      = 100   # open state for session
  PRIMARY   = 200   # primary claim is being processed   
  SECONDARY = 300   # secondary claim is being processed
  TERTIARY  = 400   # tertiary claim is being processed
  OTHER     = 500   # if for some reason there are more than 3 insurance carriers per session
  ERROR     = 700   # session had all claims or balance bils deleted and could not be closed
  BALANCE   = 800   # balance billing being processed
  CLOSED    = 900   # closed state for session
 
  SECONDARY_STATUS = [["Primary", PRIMARY], ["Secondary", SECONDARY], ["Tertiary", TERTIARY], ["Other", OTHER]]
 
 
  def self.status(current_status)       
    case current_status
    when PRIMARY
      str = "Primary Insurance"
    when SECONDARY
      str = "Secondary Insurance"
    when TERTIARY
      str = "Tertiary Insurance"
    when OTHER
      str = "Other Insurance"
    when ERROR
      str = "No Claims or Balance Bills"
    when BALANCE
      str = "Balance Bill"
    when CLOSED
      str = "Closed"
    else # assume when session status is not knowm, defaults to open
      str = "Open"
    end
    return str
  end

  def self.abbr_status(current_status)       
    case current_status
    when PRIMARY
      str = "PriIns"
    when SECONDARY
      str = "SecIns"
    when TERTIARY
      str = "TerIn"
    when OTHER
      str = "Other"
    when ERROR
      str = "None"
    when BALANCE
      str = "BalBill"
    when CLOSED
      str = "Closed"
    else # assume when session status is not knowm, defaults to open
      str = "Open"
    end
    return str
  end
  
end