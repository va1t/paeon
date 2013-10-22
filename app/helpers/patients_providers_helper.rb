module PatientsProvidersHelper
  
  def patients_provider_subscriber(patient, patient_provider)
    @primary = patient.subscribers.all(:joins => :insurance_company, :include => :subscriber_valids)
                     
    @str = ""
    @primary.each do |p|      
      status = "Not Validated"
      p.subscriber_valids.each do |sv|
        if sv.validable_type == "PatientsProvider" && sv.validable_id == patient_provider
          status = sv.status
        end
      end      
      @str += p.insurance_company.name + ", " + status + "<br />"
      @str += p.insurance_company.main_phone
    end
    return @str.html_safe
  end

end
