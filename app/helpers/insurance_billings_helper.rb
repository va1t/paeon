module InsuranceBillingsHelper

  
  # creates the html response for ajax_diagnostic call
  def create_ins_diagnostic_select
    @str = "<select class='select_tag' id='idiagnostic_#{@var}' name='idiagnostic[#{@var}]'><option value=''></option>"    
    @codes.each do |c|
      @str += "<option value='#{c.code}'>#{c.display_codes}</option>"
    end
    @str += "</select>"
    return @str.html_safe
  end
 
  def build_ins_procedures_form
    @str = ""
    @iprocedures.each_with_index do |iprocedure, subscript|
      index = subscript + @count      
      @str += "\n<div class='cpt_form'>Select CPT Code and Modifiers:<br /><span class='modifiers'>\n"
      #build the cpt & modifier dropdowns
      @str += "<select class='code_tag' id='insurance_billing_iprocedures_attributes_#{index}_cpt_code' name='insurance_billing[iprocedures_attributes][#{index}][cpt_code]'><option value=''></option>\n"
      @cpt_codes.each do |cpt|
        @str += (cpt.code == iprocedure.cpt_code) ? "<option value='#{cpt.code}' selected='selected'>#{cpt.display_codes}</option>\n" : "<option value='#{cpt.code}'>#{cpt.display_codes}</option>\n"
      end
      @str += "</select>\n"

      #build modifiers
      [iprocedure.modifier1, iprocedure.modifier2, iprocedure.modifier3, iprocedure.modifier4].each_with_index do |modifier, modindex|      
        @str += "<select class='select_tag' id='insurance_billing_iprocedures_attributes_#{index}_modifier#{modindex+1}' name='insurance_billing[iprocedures_attributes][#{index}][modifier#{modindex+1}]'><option value=''></option>\n"
        @modifiers.each do |mod|
          @str += (mod.code == modifier) ? "<option value='#{mod.code}' selected='selected'>#{mod.display_codes}</option>\n" : "<option value='#{mod.code}'>#{mod.display_codes}</option>\n"
        end      
        @str += "</select>\n"
      end
      
      @str += "</span>"
      #if record has an id, then show the delete button
      if iprocedure.id
        @str += "<span class='del'>\n"
        @str += "<a href='/insurance_sessions/#{@insurance_billing.insurance_session_id}/insurance_billings/#{@insurance_billing.id}/iprocedures/#{iprocedure.id}' data-method='delete' rel='nofollow'><img alt='Delete' border='0' height='20' src='/assets/del-button.png' title='Delete' width='20' /></a>\n"
        @str += "</span>\n<br />\n"
      end
      @str += "<div class='rate_fields'><div class='rate_id'>Rate:<br />" 
      
      #build the rate dropdown
      @str += "<select class='rate_tag' id='insurance_billing_iprocedures_attributes_#{index}_rate_id' name='insurance_billing[iprocedures_attributes][#{index}][rate_id]'><option value=''></option>\n"
      @rates.each do |r|
         @str += (r.id == iprocedure.rate_id) ? "<option value='#{r.id}' selected='selected'>#{r.rate_name}</option>\n" : "<option value='#{r.id}'>#{r.rate_name}</option>\n"  
      end
      @str += "</select>\n</div>"
      #build the rate overrride
      @str += "<div class='rate_override'>Override:<br />"
      @str += "<input autocomplete='off' class='dollar' id='insurance_billing_iprocedures_attributes_#{index}_rate_override' name='insurance_billing[iprocedures_attributes][#{index}][rate_override]' size='30' type='text' />"
      @str += "</div>\n"
      #build units
      @str += "<div class='units'>Units:<br />"
      @str += "<input autocomplete='off' class='field' id='insurance_billing_iprocedures_attributes_#{index}_units' name='insurance_billing[iprocedures_attributes][#{index}][units]' size='30' type='text' />\n"
      @str += "</div>"
      #build sessions
      @str += "<div class='sessions'>Sessions:<br />"
      @str += "<input autocomplete='off' class='field' id='insurance_billing_iprocedures_attributes_#{index}_sessions' name='insurance_billing[iprocedures_attributes][#{index}][sessions]' size='30' type='text' />\n"
      @str += "</div>"
      #build total
      @str += "<div class='total'>Total:<br />"
      @str += "<input autocomplete='off' class='dollar' id='insurance_billing_iprocedures_attributes_#{index}_total_charge' name='insurance_billing[iprocedures_attributes][#{index}][total_charge]' size='30' type='text' />\n"
      @str += "</div>"
      #end of cpt_form
      @str += "</div></div>\n"  
    end
    
    return @str.html_safe
  end
  
  
  #
  # called by insurance_billing/sidebar_right
  # also called by _patient_claim partial
  # sums the eob payments 
  #
  def ins_billing_eob_payments(billing)
    payment = 0
    billing.eobs.each do |eob|
      payment += eob.payment_amount
    end
    return payment
  end
end
