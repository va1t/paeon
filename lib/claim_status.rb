
#
# In processing the 835, there is a claim status indicator
# in the eob table, this claim status indicator is stored.
# This class stores the various indicator codes as constants and returns the definiton  
#
class ClaimStatus
  
  #these are the 835 status that are not marked "not advised"
  PRIMARY = 1
  SECONDARY = 2
  TERTIARY = 3
  DENIED = 4
  PRIMARY_FORWARDED = 19
  SECONDARY_FORWARDED = 20
  TERTIARY_FORWARDED = 21
  REVERSAL = 22
  NOT_OUR_CLAIM = 23
  PRICING_ONLY = 25
  
  
  def self.definition(code)    
    case code.to_i
      when PRIMARY
        str = "Processed as Primary Insurance"
      when SECONDARY
        str = "Processed as Secondary Insurance"
      when TERTIARY
        str = "Processed as Tertiary Insurance"
      when DENIED
        str = "Denied"
      when PRIMARY_FORWARDED
        str = "Processed as Primary, forwarded to additional payers"
      when SECONDARY_FORWARDED
        str = "Processed as Secondary, forwarded to additional payers"
      when TERTIARY_FORWARDED
        str = "Processed as Tertiary, forwarded to additional payers"
      when REVERSAL
        str = "Reversal of Previous Payment"
      when NOT_OUR_CLAIM
        str = "Nor our claim, forwarded to additional payers"
      when PRICING_ONLY
        str = "Predetermination pricing only, no payment"
      else
        str = "Unknown"
    end
    return str
  end
end
   