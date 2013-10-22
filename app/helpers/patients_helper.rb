module PatientsHelper
  
  def patients_diagnostic_table
    @diag_string = "<table class='table'>"
    
    @diag_code.each_with_index do |dia, index|
      if !dia.icd9_code.blank?
          @str = "ICD 9"
          @code = dia.icd9_code
      elsif !dia.icd10_code.blank?
          @str = "ICD 10"
          @code = dia.icd10_code
      elsif !dia.dsm_code.blank?
          @str = "DSM"
          @code = dia.dsm_code
      elsif !dia.dsm4_code.blank?
          @str = "DSM IV"
          @code = dia.dsm4_code
      else
          @str = "DSM V"
          @code = dia.dsm5_code
      end    
      
      @diag_string += "<tr><td>#{index + 1}</td><td><b>#{@str}:</b></td><td>#{@code}</td><td>"
      @diag_string += link_to image_tag('del-button.png', :alt => 'Delete', :title => 'Delete', :border => 0, :width => 20, :height => 20), patient_idiagnostic_path(@patient.id, dia.id), :method => :delete
      @diag_string += "</td></tr>"
    end 
    @diag_string += "</table>"
    return @diag_string.html_safe
  end
  
  
  # creates the html response for ajax_diagnostic call
  def create_diagnostic_select
    @str = "<select class='select_tag' id='idiagnostic_#{@var}' name='idiagnostic[#{@var}]'><option value=''></option>"
    @codes.each do |c|
      @str += "<option value='#{c.code}'>#{c.display_codes}</option>"
    end
    @str += "</select>"
    return @str.html_safe
  end
  
  def patients_groups_name(patient)        
    @groups = patient.groups
    @str = ""
    @groups.each do |g|
      @str += g.group_name + "<br />"
    end
    return (!@groups.blank? ? @str.html_safe : "None")
  end
  
  def patients_providers_name(patient)
    @provider = patient.providers
    @str = ""
    @provider.each do |t|
      @str += t.provider_name + "<br />"
    end
    return (!@provider.blank? ? @str.html_safe : "None")
  end
  
  def subscriber_name(patient)
    @primary = patient.subscribers.find(:all, :conditions => ["ins_priority = ?", Subscriber::INSURANCE_PRIORITY[0]], :joins => [:insurance_company])   
    return (!@primary.blank? ? @primary.first.insurance_company.name : "None")
  end
  
  
  #
  # creates the html code to be inserted into the seach_dialog div 
  # jquery dialog then uses this html inside a dialog popup box
  def patient_search(patients)   
    @str = ""
    patients.each do |c|
      @str += link_to "#{c.last_name}, #{c.first_name}", patient_path(c.id) 
      @str += "<br />"
    end      
    return @str.html_safe  
  end
  
  #
  # formats the results from a check for duplicate patient ajax call
  # the results are displayed in the duplicate div tags in the new.html file
  def patient_check_duplicate(patients)
    # display the duplictae patient using the form_errors css
    @str = "<div class = 'duplicate_patient'>"
    @str += "<h2>Duplicate Patient(s) found:</h2><ul>"
    patients.each do |c|
      # format the link to the patient
      @str += "<li>"
      @str += link_to "#{c.last_name}, #{c.first_name}", patient_path(c.id)
      @str += " - DOB: #{c.dob.strftime('%m/%d/%Y')},  SSN: #{c.ssn_number}"
      @str += "</li>"      
    end 
    @str += "</ul></div>"
    return @str.html_safe
  end
  
end
