
class EobCodes
  
  CO = "Contractal Obligations"
  CR = "Correction and Reversal"
  OA = "Other Adjusments"
  PI = "Payor Initiated Reductions"
  PR = "Payor Responsibility"
  
  
  def self.adjustment_group_code(code)
    case code
    when "CO"
      return CO
    when "CR"
      return CR
    when "OA"
      return OA
    when "PI"
      return PI
    when "PR"
      return PR
    else
      return "Error with code"
    end
  end
  
end