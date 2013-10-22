#
# In processing the 835, there is a claim filing indicator code
# in the eob table, this claim fiing indicator is stored as claim_indicator_code
# This class stores the various indicator codes as constants and returns the definiton  
#

class ClaimFilingIndicator
  
  PPO = "12"
  POS = "13"
  EPO = "14"
  INDEMNITY = "15"
  HMO_MEDICARE_RISK = "15"
  AUTOMOBILE_MEDICAL = "AM"
  CHAMPUS = "CH"
  DISABILITY = "DS"
  HMO = "HM"
  LIABILITY_MEDICAL = "LM"
  MEDICARE_PART_A = "MA"
  MEDICARE_PART_B = "MB"
  MEDICAID = "MC"
  OTHER_FEDERAL_PROGRAM = "OF"
  TITLE_V = "TV"
  VETERAN_ADMIN = "VA"
  WORKERS_COMP = "WC"
  
  def self.definition(code)
    case code    
      when PPO
        str = "Preferred Provider Organization (PPO)"
      when POS
        str = "Point of Service (POS)"
      when EPO
        str = "Exclusive Provider Organization (EPO)"
      when INDEMNITY
        str = "Indemnity Insurance"
      when HMO_MEDICARE_RISK
        str = "HMO Medicare Risk"
      when AUTOMOBILE_MEDICAL
        str = "Automobile Medical"
      when CHAMPUS
        str = "Champus"
      when DISABILITY
        str = "Disability"
      when HMO
        str = "Health Maintenance Organization (HMO)"
      when LIABILITY_MEDICAL
        str = "Liability Medical"
      when MEDICARE_PART_A
        str = "Medicare Part A"
      when MEDICARE_PART_B
        str = "Medicare Part B"
      when MEDICAID
        str = "Medicaid"
      when OTHER_FEDERAL_PROGRAM
        str = "Other Federal Program"
      when TITLE_V
        str = "Title V"
      when VETERAN_ADMIN
        str = "Veteran Administration Plan"
      when WORKERS_COMP
        str = "Workers' Compensation Health Claim"
      else
        str = "Unknown"
    end
    return str
  end
end