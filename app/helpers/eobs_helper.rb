module EobsHelper
  
  # creates the html for the claim select box on the new/edit eob screen
  # when ajax is evoked
  def eob_claim_select(claims)    
    str = "Select Open Claim:<br><select id='eob_insurance_billing_id' name='eob[insurance_billing_id]'><option value=''></option>"
    str += options_for_select(claim_select_text(claims))       
    str += "</select>"
    return str.html_safe
  end
  
  
  # creates the text string used in the claim select box.  Called form the helper and the edit/new form
  # returns an array to be used in options_for_select helper
  def claim_select_text(claims)
    text_array = []
    claims.each do |c|      
      text = "DOS:#{c.insurance_session.dos.strftime("%m/%d/%Y")}, $#{c.insurance_billed}, #{c.subscriber.insurance_company.name if c.subscriber}"
      text_array.push [text, c.id] 
    end
    return text_array
  end
  
  
  # creates the html for the patient_sidebar information area
  def eob_patient_sidebar(patient)
    str = "<b>Patient:</b> "
    str += "<a href='/patients/#{patient.id}'>#{patient.patient_name}</a><br />"
    str += "DOB: #{patient.dob.strftime("%m/%d/%Y")}<br />"
    str += "<b>Address:</b><br />"
    str += "#{patient.address1}<br />"
    if !patient.address2.blank?
      str += "#{patient.address2}<br />"
    end
    str += "#{patient.city}, #{patient.state} #{patient.zip}<br />"
    return str.html_safe
  end
  
  
  # creates the html for the subscriber_sidebar information area
  def eob_subscriber_sidebar(claim)
    insured = claim.subscriber
    str = "<b>Subscriber:</b><br /><b>#{insured.subscriber_name}</b><table>"
    str += "<tr><td><b>Relationship:</b></td><td> #{insured.type_patient}</td></tr>" 
    str += "<tr><td><b>Group:</b></td><td> #{insured.ins_group}</td></tr><tr><td><b>Policy:</b></td><td> #{insured.ins_policy}</td></tr>"    
    str += "<tr><td><b>Priority:</b></td><td> #{insured.ins_priority}</td></tr>"
    str += "<tr><td><b>DOB:</b></td><td> #{insured.subscriber_dob.strftime("%m/%d/%Y") if !insured.subscriber_dob.blank?}</td></tr><tr><td><b>Gender:</b></td><td> #{insured.subscriber_gender}</td></tr></table>"
    return str.html_safe
  end
  
  
  # creates the html for the claim_sidebar information area
  def eob_claim_sidebar(claim)
    str = "<b>Submitted Claim:</b><br />"
    str += "<table>"
    str += "<tr><td>Claim Number:</td><td>#{claim.claim_number}</td></tr>"
    str += "<tr><th>Copay:</th><td>#{number_to_currency(claim.insurance_session.copay_amount)}</td></tr>"
    str += "<tr><th>Lab Charges:</th><td>$</td></tr>"
    str += "<tr><td>---------</td></tr>"
    str += "<tr><td>CPT</td><td>Charge</td></tr>"    
    claim.iprocedures.each do |procedure|
      str += "<tr><td>#{procedure.cpt_code}</td><td>#{number_to_currency(procedure.total_charge)}</td></tr>"
    end
    str += "<tr><th>Sub Total:</th><td>#{number_to_currency(claim.insurance_billed)}</td></tr>"
    str += "<tr><td>---------</td></tr>"
    if !claim.insurance_session.ins_allowed_amount.blank? && claim.insurance_session.ins_allowed_amount > 0 
      str += "<tr><th>Allowed Amt:</th><td>#{number_to_currency(claim.insurance_session.ins_allowed_amount)}</td></tr>"
    else
      str += "<tr><th>Charges:</th><td>#{number_to_currency(claim.insurance_session.charges_for_service)}</td></tr>"
    end
    str += "<tr><th>Ins Paid:</th><td>#{number_to_currency(claim.insurance_session.ins_paid_amount)}</td></tr>"
    str += "<tr><th>Bal Bill Paid:</th><td>#{number_to_currency(claim.insurance_session.bal_bill_paid_amount.blank? ? 0 : claim.insurance_session.bal_bill_paid_amount)}</td></tr>"
    str += "<tr><th>Waived Fee:</th><td>#{number_to_currency(claim.insurance_session.waived_fee.blank? ? 0 : claim.insurance_session.waived_fee)}</td></tr>"
    str += "<tr><th>Balance Due:</th><td>#{number_to_currency(claim.insurance_session.balance_owed)}</td></tr>"
    str += "</table>"
    return str.html_safe
  end
  
  # creates the html for the ajax_unassigned request on the eob_unassigned screen
  def eob_open_claims(claims)
    str = "<div class='claim_table'><h2>Open Claims:</h2>"
    str += "<table><tr><th></th><th>DOS</th><th>Patient</th><th>Provider</th><th>Group</th><th>Payor</th></tr>"
    
    claims.each do |claim|
      str += "<tr><td><input id='eob_insurance_billing_id_5' name='eob[insurance_billing_id]' type='radio' value='5' /></td>"          
      str += "<td>#{claim.dos.strftime('%m/%d/%Y')}</td>"
      str += "<td>#{claim.patient.patient_name}</td>"
      str += "<td>#{claim.Provider.Provider_name}</td>"
      str += "<td>#{claim.group.group_name if claim.group}</td>"
      str += "<td>#{claim.insurance_company.name}</td></tr>"      
    end

    str += "</table><div class='button'><input class='submit' name='commit' type='submit' value='Update Eob' /></div></div>"
    return str.html_safe
  end
  
end




