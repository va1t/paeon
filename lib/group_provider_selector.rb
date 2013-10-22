#
# The Selector class allows the selection between a group or provider within the sessions.
# This decides which NPI and CPT/DIAG will be used in billing the claim
# as well as deciding which information set to display on various screens
#
class Selector
 
 GROUP    = 100
 PROVIDER = 200
 PATIENT   = 300
 
 
 def self.selection(code)
   case code
   when GROUP
     str = "Group"
   when PROVIDER
     str = "Provider"
   when PATIENT
     str = "Patient"
   else
     str = "No Selection"
   end
   return str
 end

end