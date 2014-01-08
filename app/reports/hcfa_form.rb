class HcfaForm < Prawn::Document

  # initilaze the pdf report
  # takes an array of all the claim ids
  # sets up the default pages settings
  def initialize(claims, use_form = true)
    @claims = claims
    @use_form = use_form

    # call the initilize function in prawn::document
    super(:margin => 25)

    # get the image of the 1500 form
    @image = "#{Rails.root}/public/assets/1500.png"
    # fill in the form for the first page
    if @use_form
       canvas do
         image @image, :width => bounds.width
       end
    end

    # set the default font
    font "Helvetica"
    font_size 10
  end


  # loops through all the claim ids
  # pulls the data from the database
  # assembles each page
  def build
    @insurance_billings = InsuranceBilling.find_all_by_id(@claims,
                                           :include => [:insurance_session, :subscriber, :patient, :idiagnostics, :iprocedures],
                                           :order => "patient_id ASC")

    patient_id = 0
    count = 0
    # used for totals
    @charges_for_service = 0
    @copay_amount = 0
    @balance_owed = 0

    @insurance_billings.each do |insurance_billing|
      #pull the session
      #insurance_session = InsuranceSession.find(insurance_billing.insurance_session_id)
      insurance_session = insurance_billing.insurance_session

      # if same patient and less than 6 claims, add the claim to the same form
      if patient_id == insurance_billing.patient_id && count < 6
        count += get_claim_info(count, insurance_billing, insurance_session)
      else  # start a new page
        if patient_id != 0
          #add the totals on the page before starting a new one
          get_charges
          # start a new page; skip the first time because the initial page is already created
          start_new_page
          #reset the totals for the next page
          @charges_for_service = 0
          @copay_amount = 0
          @balance_owed = 0

          # add the form image if it is requested
          if @use_form
              canvas do
                image @image, :width => bounds.width
              end
          end
        end
        fill_in_form(insurance_billing, insurance_session)
        count = get_claim_info(0, insurance_billing, insurance_session)
        patient_id = insurance_billing.patient_id
      end
    end
    #add the last set of charges to the last page
    get_charges
  end


  private

  def fill_in_form(insurance_billing, insurance_session)
      #patient = insurance_session.patient
      patient = insurance_billing.patient

      # take the selected insurance ocmpnay and subscriber information and fill in hte upper right hand side of the hcfa form
      subscriber = insurance_billing.subscriber
      insurance_company = subscriber.insurance_company
      get_header(insurance_company)

      # if more than one claim, the current claim is secondary and the first claim is primary
      if insurance_billing.secondary_status != SessionFlow::PRIMARY
        # get the first subscriber information to fill in the middle left hand side of the hcfa form
        second_subscriber = insurance_session.insurance_billings.first.subscriber
        second_insurance_company = second_subscriber.insurance_company
        get_secondary_header
        secondary_insurance(second_subscriber, second_insurance_company)     #second_subscriber && second_insurance_company
      end
      get_patient_info(patient)        #patient variable
      get_insured_info(subscriber, insurance_company)        #subscriber && insurance_company
      get_patient_signatures(patient, insurance_billing)  #patient && subscriber

      if insurance_session.patient_injury
        patient_injury = insurance_session.patient_injury
        get_history_info(patient_injury)   # patient_injury
      else
        get_default_history     # set box 10 cbk's to no
      end

      get_managed_care(insurance_billing.managed_care) if insurance_billing.managed_care
      get_refering_provider(patient)   #uses patient

      #provider & group
      get_provider_info(insurance_session, insurance_billing, patient, insurance_company)
      return
    end

    #
    # displays the word secondary insurace across the top of the 1500 form
    #
    def get_secondary_header
      text_box "Secondary Insurance", :at => [205, 752]
    end

    #
    # add the insurance company the form is being sent to at the top
    # in the header section of the form
    #
    def get_header(ins_company)
      header = ins_company.name + "\n"
      header += !ins_company.insurance_co_id.blank? ? (ins_company.insurance_co_id + "\n") : ""
      header += ins_company.address1 + "\n"
      header += !ins_company.address2.blank? ? (ins_company.address2 + "\n") : ""
      header += ins_company.city + ", " + ins_company.state + "  " + ins_company.zip
      text_box header, :at => [355,732], :height => 100, :width => 100
    end

    #
    # fillin the patient related boxes on the form
    #
    def get_patient_info(patient)
      # box 2 maps to patient name
      text_box patient.patient_name, :at => [5, 633]
      # box 3 maps to patient dob and gender
      text_box patient.dob.strftime("%m"), :at => [215, 632]
      text_box patient.dob.strftime("%d"), :at => [235, 632]
      text_box patient.dob.strftime("%y"), :at => [255, 632]
      if patient.gender == Patient::GENDER[0] #male
        text_box "X", :at => [296, 631]
      else
        text_box "X", :at => [332, 631]
      end

      # box 5 maps to patient
      if patient.address2
        text_box patient.address1 + ", " + patient.address2, :at => [5, 608]
      else
        text_box patient.address1, :at => [5, 608]
      end
      text_box patient.city, :at => [5, 585]
      text_box patient.state, :at => [183, 585]
      text_box patient.zip, :at => [5, 561]
      text_box patient.home_phone, :at => [100, 561]


      # box 8 maps to patient, patient status and relationship status
      case patient.relationship_status
      when Patient::RELATIONSHIP[0]
        text_box "X", :at => [245, 583]
      when Patient::RELATIONSHIP[1]
        text_box "X", :at => [288, 583]
      else # other
        text_box "X", :at => [330, 583]
      end

      case patient.patient_status
      when Patient::PATIENT_STATUS[0]
        text_box "X", :at => [245, 559]
      when Patient::PATIENT_STATUS[1]
        text_box "X", :at => [288, 559]
      else #part time student
        text_box "X", :at => [330, 559]
      end
    end

    #
    # fill in the primary insured information
    #
    def get_insured_info(subscriber, insurance_company)
      # box 1 maps to subscriber, type of insurance
      case subscriber.type_insurance
      when "Medicare"
        # the check box is before the left margin
        text_box "X", :at => [2, 654]
      when "Medicaid"
        text_box "X", :at => [50, 654]
      when "Tricare Champus"
        text_box "X", :at => [101, 654]
      when "ChampVA"
        text_box "X", :at => [165, 654]
      when "Group"
        text_box "X", :at => [216, 654]
      else #"other"
        text_box "X", :at => [316, 654]
      end

      # box 1a maps to subscriber, policy number
      text_box subscriber.ins_policy, :at => [355, 656]
      # box 4 maps to clinet_insured subscribers name
      text_box subscriber.subscriber_name, :at => [355, 633]

      # box 6 maps to subscriber, type_patient
      case subscriber.type_patient
      when "Self"
        text_box "X", :at => [231, 607]
      when "Spouse"
        text_box "X", :at => [267, 607]
      when "Child"
        text_box "X", :at => [296, 607]
      else #other
        text_box "X", :at => [331, 607]
      end

      # box 7 maps to subscriber, subscriber
      if subscriber.subscriber_address2
        text_box subscriber.subscriber_address1 + ", " + subscriber.subscriber_address2, :at => [355, 608]
      else
        text_box subscriber.subscriber_address1, :at => [355, 608]
      end
      text_box subscriber.subscriber_city, :at => [355, 585]
      text_box subscriber.subscriber_state, :at => [530, 585]
      text_box subscriber.subscriber_zip, :at => [355, 561]
      # box 11 is the group number in subscriber
      text_box subscriber.ins_group, :at => [355, 537]
      # box 11 maps to subscriber dob and gender
      if !subscriber.subscriber_dob.blank?
        text_box subscriber.subscriber_dob.strftime("%m"), :at => [380, 511]
        text_box subscriber.subscriber_dob.strftime("%d"), :at => [396, 511]
        text_box subscriber.subscriber_dob.strftime("%y"), :at => [418, 511]
      end
      if subscriber.subscriber_gender == Patient::GENDER[0] #male
        text_box "X", :at => [482, 511]
      else
        text_box "X", :at => [533, 511]
      end
      # box 11b - subscriber employer
      text_box subscriber.employer_name, :at => [355, 489]
      # box 11c - subscriber plan name
      text_box insurance_company.name, :at => [355, 465]
    end


    #
    # fields need to be set specifically for secondary insurance
    #
    def secondary_insurance(second_subscriber, second_insurance_company)
      # box 9 maps to subscriber subscribers name
      text_box second_subscriber.subscriber_name, :at => [5, 537]
      # box 9a maps to subscriber, policy number
      text_box second_subscriber.ins_policy, :at => [5, 513]

      # box 11 maps to subscriber dob and gender
      text_box second_subscriber.subscriber_dob.strftime("%m"), :at => [13, 488]
      text_box second_subscriber.subscriber_dob.strftime("%d"), :at => [28, 488]
      text_box second_subscriber.subscriber_dob.strftime("%y"), :at => [50, 488]
      if second_subscriber.subscriber_gender == Patient::GENDER[0] #male
        text_box "X", :at => [124, 488]
      else
        text_box "X", :at => [166, 488]
      end
      # box 9c - subscriber employer
      text_box second_subscriber.employer_name, :at => [5, 465]
      # box 9d - subscriber plan name
      text_box second_insurance_company.name, :at => [5, 441]
    end


    #
    # if the signature check boxes are true the add "on file" to the signature fields
    #
    def get_patient_signatures(patient, insurance_billing)
      if patient.signature_on_file
        text_box  "Signature on File", :at => [40, 394]
        # add todays date
        if insurance_billing.status >= BillingFlow::SUBMITTED
          text_box  insurance_billing.claim_submitted.strftime("%m/%d/%Y"), :at => [255, 394]
        else
          text_box  DateTime.now.strftime("%m/%d/%Y"), :at => [255, 394]
        end

        text_box  "Signature on File", :at => [395, 394]
      end
    end


    def get_default_history
      text_box "X", :at => [289, 511]
      text_box "X", :at => [289, 488]
      text_box "X", :at => [289, 464]
    end


    #
    # get the dates for illness, therapy, work and hospitalization
    #
    def get_history_info(patient_injury)
      case patient_injury.accident_type
      when "Employment"  # box 10a
        text_box "X", :at => [245, 511]
        #check the no boxs
        text_box "X", :at => [289, 488]
        text_box "X", :at => [289, 464]
      when "Auto"        # box 10b
        text_box "X", :at => [245, 488]
        text_box patient_injury.accident_state, :at => [318, 488]
        #check the no boxes
        text_box "X", :at => [289, 511]
        text_box "X", :at => [289, 464]
      when "Other"       # box 10c
        text_box "X", :at => [245, 464]
        # check the no boxes
        text_box "X", :at => [289, 488]
        text_box "X", :at => [289, 464]
      end

      #box 16 - unable to work
      if patient_injury.unable_to_work_start
        text_box patient_injury.unable_to_work_start.strftime("%m"), :at => [388, 367]
        text_box patient_injury.unable_to_work_start.strftime("%d"), :at => [408, 367]
        text_box patient_injury.unable_to_work_start.strftime("%y"), :at => [425, 367]
      end
      if patient_injury.unable_to_work_stop
        text_box patient_injury.unable_to_work_stop.strftime("%m"), :at => [487, 367]
        text_box patient_injury.unable_to_work_stop.strftime("%d"), :at => [504, 367]
        text_box patient_injury.unable_to_work_stop.strftime("%y"), :at => [523, 367]
      end

      #box 18 - hospitalization
      if patient_injury.hospitalization_start
        text_box patient_injury.hospitalization_start.strftime("%m"), :at => [388, 343]
        text_box patient_injury.hospitalization_start.strftime("%d"), :at => [408, 343]
        text_box patient_injury.hospitalization_start.strftime("%y"), :at => [425, 343]
      end
      if patient_injury.hospitalization_stop
        text_box patient_injury.hospitalization_stop.strftime("%m"), :at => [487, 343]
        text_box patient_injury.hospitalization_stop.strftime("%d"), :at => [504, 343]
        text_box patient_injury.hospitalization_stop.strftime("%y"), :at => [523, 343]
      end
      # box 14
      text_box patient_injury.start_illness.strftime("%m"), :at => [14, 367]
      text_box patient_injury.start_illness.strftime("%d"), :at => [32, 367]
      text_box patient_injury.start_illness.strftime("%y"), :at => [50, 367]
    end


    #
    # get the pre-authorizations for the claim
    # box 23
    def get_managed_care(managed_care)
      text_box managed_care.authorization_id, :at => [360, 272]
    end

    #
    # get the refering provider and fill in boxs 17 & 17b
    #
    def get_refering_provider(patient)
      # if there is an NPI for the refering, then fill in the boxes
      # otherwise the refering person is not a physician
      # box 17
      if patient.referred_from_npi
        text_box patient.referred_from, :at => [5, 347]
        text_box patient.referred_from_npi, :at => [225, 344]
      end
    end


    def get_claim_info(count, insurance_billing, insurance_session)

      idiagnostics = insurance_billing.idiagnostics
      iprocedures = insurance_billing.iprocedures

      #set the diagnostic codes
      idiagnostics.each_with_index do |diag, index|
        case index
          when 0
            x = 15; y = 298
          when 1
            x = 15; y = 275
          when 2
            x = 210; y = 298
          when 3
            x = 210; y = 275
          when 4
            x = 270; y = 275
        end

        if index < 5 #1500 form has a limit of 4 diagnostic codes; the 5th code can be squeezed onto the form
          if !diag.dsm_code.blank?
            text_box diag.dsm_code, :at => [x, y]
          elsif !diag.icd9_code.blank?
            text_box diag.icd9_code, :at => [x, y]
          elsif !diag.dsm4_code.blank?
            text_box diag.dsm4_code, :at => [x, y]
          elsif !diag.dsm5_code.blank?
            text_box diag.dsm5_code, :at => [x, y]
          elsif !diag.icd10_code.blank?
            text_box diag.icd10_code, :at => [x, y]
          end
        end # end if index...
      end  # end of do each...

      #set the value for the diagnostic pointer
      case idiagnostics.size
        when 1
          diag_ptr = '1'
        when 2
          diag_ptr = '1-2'
        when 3
          diag_ptr = '1-3'
        when 4
          diag_ptr = '1-4'
        else
          diag_ptr = '1-5'
      end

      #set the procedure codes
      iprocedures.each_with_index do |proc, i|
        index = i + count
        #date of service start
        text_box insurance_session.dos.strftime("%m"), :at => [5, 230 - (index * 24)]
        text_box insurance_session.dos.strftime("%d"), :at => [25, 230 - (index * 24)]
        text_box insurance_session.dos.strftime("%y"), :at => [45, 230 - (index * 24)]
        #date of service stop
        text_box insurance_session.dos.strftime("%m"), :at => [70, 230 - (index * 24)]
        text_box insurance_session.dos.strftime("%d"), :at => [90, 230 - (index * 24)]
        text_box insurance_session.dos.strftime("%y"), :at => [110, 230 - (index * 24)]
        #place of service
        text_box insurance_session.pos_code.to_s, :at => [130, 230 - (index * 24)]
        #cpt and modifiers
        text_box proc.cpt_code, :at => [177, 230 - (index * 24)]

        #modifiers may have been entered skipping spaces
        [proc.modifier1, proc.modifier2, proc.modifier3, proc.modifier4].each_with_index do |mod, mi|
          text_box mod, :at => [225 + (mi * 23), 230 - (index * 24)] if !mod.blank?
        end

        #deal with diagnostic pointer
        text_box diag_ptr, :at => [ 335, 230 - (index * 24)]

        # enter the charge from the rate_id or rate_override
        rate = !proc.rate_override.blank? ? sprintf("%.2f", proc.rate_override) : (proc.rate.blank? ? "0.00" :sprintf("%.2f", proc.rate.rate))
        text_box rate, :at => [375, 230 - (index * 24)]

        # box 24j  fillin the rendering provider NPI
        # need to determine if medicare claim; if provider leave blank.  if group fill in
        medicare = insurance_billing.subscriber.type_insurance == "Medicare" ? true : false
        if !medicare || insurance_session.group?
          text_box insurance_session.provider.npi, :at => [ 480, 223 - (index * 24)]
        end
      end  #end of iprocedures.each ....
      @charges_for_service += insurance_session.charges_for_service
      @copay_amount += insurance_session.copay_amount
      @balance_owed += insurance_session.balance_owed
      return iprocedures.count  # return the count of cpts to add to the total count
    end


    #
    # charges need to be sumed up and printed for all charges for service included on the claim
    #
    def get_charges
      #fill in the remaining claim info
      # box 28
      text_box sprintf("%.2f", @charges_for_service.to_s), :at => [370, 82]
      # box 29
      text_box sprintf("%.2f", @copay_amount.to_s), :at => [450, 82]
      # box 30
      text_box sprintf("%.2f", @balance_owed.to_s), :at => [520, 82]
    end


    #
    #
    #
    def get_provider_info(insurance_session, insurance_billing, patient, insurance_company)
      rendering_provider = insurance_session.provider
      provider_insurance = rendering_provider.provider_insurances.find_by_insurance_company_id(insurance_company)
      service_office = insurance_session.office
      billing_office = insurance_session.billing_office
      # in case the billign office is blank, then use the session office
      billing_office = insurance_session.office if billing_office.blank?

      if insurance_session.group?
        group = insurance_session.group
        #box 25 ein number
        if provider_insurance && !provider_insurance.ein_suffix.blank?
          text_box group.ein_number + provider_insurance.ein_suffix, :at => [5, 82]
        else
          text_box group.ein_number, :at => [5, 82]
        end
        text_box "X", :at => [130, 80]
      else
        #box 25 ssn or ein number
        if !rendering_provider.ein_number.blank?
          if provider_insurance && !provider_insurance.ein_suffix.blank?
            text_box rendering_provider.ein_number + provider_insurance.ein_suffix, :at => [5, 82]
          else
            text_box rendering_provider.ein_number, :at => [5, 82]
          end
          text_box "X", :at => [130, 80]
        else
          text_box rendering_provider.ssn_number, :at => [5, 82]
          text_box "X", :at => [115, 80]
        end
      end

      #box 26 - patient account number, enter the unique claim number
      text_box patient.id.to_s + '-' + DateTime.now.strftime('%m%d%Y'), :at => [160, 82]

      #box 27 - accepts assignment, maps to patient.accepts_assignement
      if patient.accept_assignment
        text_box "X", :at => [267, 80]
      else
        text_box "X", :at => [303, 80]
      end

      #box 31 signature on file maps to provider
      if rendering_provider.signature_on_file
        text_box rendering_provider.provider_name, :at => [5, 40]
        text_box DateTime.now.strftime('%m/%d/%Y'), :at => [100, 25]
      end
      #box 32, 33 office & provider info
      #collect & format the service facility office
      service = insurance_session.group? ? group.group_name : rendering_provider.provider_name
      service += "\n" + service_office.address1
      service += !service_office.address2.blank? ? (", " + service_office.address2) : ""
      service += "\n" + service_office.city + ", " + service_office.state + "  " + service_office.zip
      #collect & format the billing office
      billing = rendering_provider.provider_name
      billing += "\n" + billing_office.address1
      billing += !billing_office.address2.blank? ? (", " + billing_office.address2) : ""
      billing += "\n" + billing_office.city + ", " + billing_office.state + "  " + billing_office.zip

      # box 32
      text_box service, :at => [165, 60]

      # as of 9/3/13; boxes 32a and 32b should be blank.
      # box 32a
      # text_box rendering_provider.npi, :at => [165, 20]
      # box 32b
      # text_box rendering_provider.npi, :at => [245, 20]

      # box 33 - phone number
      text_box rendering_provider.office_phone, :at => [470, 70]
      # box 33
      text_box billing, :at => [365, 60]
      # box 33a
      if insurance_session.group?
        text_box group.npi, :at => [365, 20]
      else
        text_box rendering_provider.npi, :at => [365, 20]
      end

    end


end
