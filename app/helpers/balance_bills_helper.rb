module BalanceBillsHelper
  
  #
  # redraws the select box for the unique patients related to the selected provider
  # the @unique_patients variable is an array with patients name in 0 and id in 1
  #
  def balance_bill_patients_dropdown
    
    str = "<b>Select Patient:</b><br>"
    str += "<select id='patient_id' name='patient_id'><option value=''></option>"
    @unique_patients.each do |u|
      str += "<option value='#{u[1]}' "
      if @patient && @patient.id == u[1]
        str += "selected='selected' "
      end
      str += ">#{u[0]}</option>"
    end
    str += "</select>" 
    return str.html_safe
  end
  
  def balance_bill_hidden_fields
    str = "<input id='balance_bill_patient_id' name='balance_bill[patient_id]' "
    str += "value='#{params[:patient_id]}' " if params[:patient_id]
    str += "type='hidden'>"
    str += "<input id='balance_bill_provider_id' name='balance_bill[provider_id]' "
    str += "value='#{params[:provider_id]}' " if params[:provider_id]
    str += "type='hidden'>"
    return str.html_safe
  end  

end
