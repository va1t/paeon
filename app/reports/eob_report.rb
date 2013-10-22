class EobReport < Prawn::Document
  
  #initilaze the pdf report and retrieve the data from the database
  def initialize(id)
    # call the initilize function in prawn::document
    @top_margin = 60
    @bottom_margin = 50
    super(:bottom_margin => @bottom_margin, :top_margin => @top_margin)
              
    # set the default font
    font "Helvetica"
    font_size 8
    @title_size = 12
    
    # pull the data from the database
    @eob = Eob.find(id)    
    @details = @eob.eob_details
    @insurance_billing = @eob.insurance_billing
    @unassigned = @insurance_billing.blank? ? true : false  #eob is not linked to a claim if insurance billing is blank  
    @insurance_company = @eob.insurance_company
  end
  
  
  def build
    repeat :all do
      header
      footer
    end
    content
  end
  
  
  private  
  
  #
  # each section of the eob has its own private method to help keep maintenance easier
  # 
  def content
      # payer bounding box
      section_bottom = bounds.top   #initialize section_bottom
      bounding_box([bounds.left, bounds.top], :width => bounds.width) do
        column_width = bounds.width / 3
        last_column_width = bounds.width - (2 * column_width)
        leftbox = bounding_box([bounds.left, bounds.top], :width => column_width) do
          build_payor_section
        end
        section_bottom = leftbox.absolute_bottom  
        middlebox = bounding_box([column_width, bounds.top], :width => column_width) do
          build_member_section
        end
        section_bottom = middlebox.absolute_bottom if middlebox.absolute_bottom < section_bottom
        rightbox = bounding_box([column_width * 2, bounds.top], :width => last_column_width) do
          build_patient_section
        end
        section_bottom = rightbox.absolute_bottom if rightbox.absolute_bottom < section_bottom
      end
      # move the cursor to the lowest of the three bounding boxes
      move_cursor_to section_bottom - @top_margin
      move_down 5
      stroke_horizontal_rule
      bounding_box([bounds.left, cursor], :width => bounds.width) do
        column_width = bounds.width / 3
        last_column_width = bounds.width - (2 * column_width)
        # provider bounding box
        leftbox = bounding_box([bounds.left, bounds.top], :width => column_width) do
          build_provider_section
        end
        section_bottom = leftbox.absolute_bottom
        # patient bounding box
        middlebox = bounding_box([column_width, bounds.top], :width => column_width) do
          build_check_section
        end
        section_bottom = middlebox.absolute_bottom if middlebox.absolute_bottom < section_bottom          
      end
      # move the cursor to the lowest of the bounding boxes
      move_cursor_to section_bottom - @top_margin
      move_down 5
      # service section - dont use bounding box so that it scales to multiple pages correctly
      stroke_horizontal_rule
      #bounding_box([bounds.left, cursor], :width => bounds.width) do
        build_detail_section
      #end
  end
  
  
  def build_payor_section
    move_down 10
    fill_color "0033CC"
    text "Insurance Company:", :style => :bold, :size => @title_size
    fill_color "000000"
    indent 20 do
      if @unassigned
        text "EOB is not assigned to a claim."
        text @eob.payor_name, :style => :bold
      else
        text @insurance_company.name, :style => :bold
        text !@insurance_company.insurance_co_id.blank? ? (@insurance_company.insurance_co_id + "\n") : ""
        text @insurance_company.address1 + "\n"
        text !@insurance_company.address2.blank? ? (@insurance_company.address2 + "\n") : ""
        text @insurance_company.city + ", " + @insurance_company.state + "  " + @insurance_company.zip       
      end
      text "<b>Payor Claim:</b> #{@eob.payor_claim_number if !@eob.payor_claim_number.blank? }", :inline_format => true
      text "<b>Status:</b> #{ClaimStatus.definition(@eob.claim_status_code) if !@eob.claim_status_code.blank? }", :inline_format => true 
    end 
  end
  
  
  def build_member_section
    move_down 10
    fill_color "0033CC"
    text "Subscriber:", :style => :bold, :size => @title_size
    fill_color "000000"
    indent 20 do 
      if @unassigned
          text @eob.subscriber_last_name + ", " + @eob.subscriber_first_name, :style => :bold
          text "<b>Policy:</b> #{@eob.subscriber_ins_policy}", :inline_format => true
          text "<b>Group:</b> #{@eob.group_number}", :inline_format => true
      else
          text @eob.subscriber.subscriber_name, :style => :bold
          text "<b>Policy:</b> #{@eob.subscriber.ins_policy}", :inline_format => true
          text "<b>Group:</b> #{@eob.subscriber.ins_group}", :inline_format => true          
          text "<b>Group Name:</b> #{@eob.subscriber.employer_name}", :inline_format => true
      end
      text "<b>EOB Date:</b> #{@eob.eob_date.strftime("%m/%d/%Y")}", :inline_format => true
      text ""
    end
  end
    
    
  def build_provider_section
    move_down 10
    fill_color "0033CC"
    text "Provider:", :style => :bold, :size => @title_size
    fill_color "000000"
    indent 20 do     
      if @unassigned
        text @eob.provider_last_name + ", " + (@eob.provider_first_name.blank? ? "" : @eob.provider_first_name), :style => :bold
      else
        text @eob.provider.provider_name, :style => :bold
      end
      text "<b>Claim Number:</b> #{@eob.claim_number}", :inline_format => true
      text "<b>Claim Date: </b> #{@eob.claim_date.strftime("%m/%d/%Y") if !@eob.claim_date.blank?}", :inline_format => true
    end
  end
  
  def build_check_section
    move_down 10
    fill_color "0033CC"
    text "Payment:", :style => :bold, :size => @title_size
    fill_color "000000"
    if @eob.payment_method =="CHK"
      indent 20 do
        text "<b>Check Number:</b> #{@eob.check_number if !@eob.check_number.blank? }", :inline_format => true
        text "<b>Check Date:</b> #{@eob.check_date.strftime("%m/%d/%Y") if !@eob.check_date.blank? }", :inline_format => true
        text "<b>Check Amount:</b> $ #{sprintf("%.2f", @eob.check_amount) if @eob.check_amount }", :inline_format => true
        if @eob.check_amount > @eob.payment_amount
          text "<b>Note:</b> The Check was bundled with other claims for the provider.", :inline_format => true
        end
      end
    elsif @eob.payment_method == "ACH"
      indent 20 do 
        text "<b>Account Transfer:</b> #{@eob.check_number if !@eob.check_number.blank? }", :inline_format => true
        text "<b>Trans Date:</b> #{@eob.check_date.strftime("%m/%d/%Y") if !@eob.check_date.blank? }", :inline_format => true
        text "<b>Amount:</b> $ #{sprintf("%.2f", @eob.check_amount) if @eob.check_amount }", :inline_format => true 
        if @eob.check_amount > @eob.payment_amount
          text "<b>Note:</b> The transaction was bundled with other claims for the provider.", :inline_format => true
        end        
      end      
    end    
  end
  
  
  def build_patient_section
    move_down 10
    fill_color "0033CC"
    text "Patient:", :style => :bold, :size => @title_size
    fill_color "000000"
    indent 20 do     
      if @unassigned        
        text @eob.patient_last_name + ", " + @eob.patient_first_name, :style => :bold
        text "<b>Date of Service:</b> #{@eob.dos.strftime("%m/%d/%Y")}", :inline_format => true
      else
        text @eob.patient.patient_name, :style => :bold
        text "<b>DOB: </b> #{@eob.patient.dob.strftime("%m/%d/%Y")}", :inline_format => true
        text "<b>Date of Service:</b> #{@eob.dos.strftime("%m/%d/%Y")}", :inline_format => true
      end
    end
  end
  
  
  def build_detail_section         
    @details.each do |detail|
        move_down 10
        fill_color "0033CC"
        text "Service:", :style => :bold, :size => @title_size
        fill_color "000000"
        indent 20 do
            # detail record
            bounding_box([bounds.left, cursor], :width => bounds.width, :height => 30) do            
              bounding_box([bounds.left, bounds.top], :width => bounds.width/2, :height => 30) do
                if detail.dos.blank?
                  text "<b>Date of Service:</b> #{@eob.dos.strftime("%m/%d/%Y")}", :inline_format => true
                else
                  text "<b>Date of Service:</b> #{detail.dos.strftime("%m/%d/%Y")}", :inline_format => true  
                end
                
                text "<b>Service Start:</b> #{detail.service_start.strftime("%m/%d/%Y") if !detail.service_start.blank?}", :inline_format => true  
              end        
              bounding_box([bounds.width/2, bounds.top], :width => bounds.width/2, :height => 30) do
                text "<b>Service End:</b> #{detail.service_end.strftime("%m/%d/%Y") if !detail.service_end.blank?}", :inline_format => true
                text "<b>Type of Service:</b> #{detail.type_of_service}", :inline_format => true  
              end        
            end
            move_down 5
            
            data = [["Billed", "Allowed", "Deductible", "Copay", "Ins Adjustment", "Not Covered", "Payment"],
                    [("$ " + sprintf("%.2f", detail.charge_amount) if !detail.charge_amount.blank?),
                     ("$ " + sprintf("%.2f", detail.allowed_amount) if !detail.allowed_amount.blank?), 
                     ("$ " + sprintf("%.2f", detail.deductible_amount) if !detail.deductible_amount.blank?), 
                     ("$ " + sprintf("%.2f", detail.copay_amount) if !detail.copay_amount.blank?), 
                     ("$ " + sprintf("%.2f", detail.other_carrier_amount) if !detail.other_carrier_amount.blank?),
                     ("$ " + sprintf("%.2f", detail.not_covered_amount) if !detail.not_covered_amount.blank?), 
                     ("$ " + sprintf("%.2f", detail.payment_amount) if !detail.payment_amount.blank?) ]] 
                     
            table data, :width=> 525, :column_widths => 75, :cell_style => {:align => :center}
            move_down 10
            text_box "Balance Due: $#{detail.subscriber_amount.blank? ? "0.00" : sprintf("%.2f", detail.subscriber_amount)}", :style => :bold, :at => [375, cursor]
                    
            # service adjustment
            move_down 15
            fill_color "0033CC"
            text "Service Adjustments:", :style => :bold, :size => @title_size
            fill_color "000000"
            detail.eob_service_adjustments.each do |adjustment|
              build_service_adjustment(adjustment)
            end
        
            # remarks
            move_down 10
            fill_color "0033CC"
            text "Remarks:", :style => :bold, :size => @title_size
            fill_color "000000"      
            detail.eob_service_remarks.each do |remark|
              build_service_remark(remark)
            end
        end
    end    
  end

  
  def build_service_adjustment(adjustment)
    data = Array.new
    carc = CodesCarc.find_by_code(adjustment.carc1)
    row = [EobCodes::adjustment_group_code(adjustment.claim_adjustment_group_code), (carc.description if !carc.blank?), ("$ " + sprintf("%.2f", adjustment.monetary_amount1)) ]
    data.push row
    if !adjustment.carc2.blank?
      carc = CodesCarc.find_by_code(adjustment.carc2)
      row = ["", (carc.description if !carc.blank?), ("$ " + sprintf("%.2f", adjustment.monetary_amount2)) ]
      data.push row
    end
    if !adjustment.carc3.blank?
      carc = CodesCarc.find_by_code(adjustment.carc3)
      row = ["", (carc.description if !carc.blank?), ("$ " + sprintf("%.2f", adjustment.monetary_amount3)) ]
      data.push row
    end
    if !adjustment.carc4.blank?
      carc = CodesCarc.find_by_code(adjustment.carc4)
      row = ["", (carc.description if !carc.blank?), ("$ " + sprintf("%.2f", adjustment.monetary_amount4)) ]
      data.push row
    end
    if !adjustment.carc5.blank?
      carc = CodesCarc.find_by_code(adjustment.carc5)
      row = ["", (carc.description if !carc.blank?), ("$ " + sprintf("%.2f", adjustment.monetary_amount5)) ]
      data.push row
    end
    if !adjustment.carc6.blank?
      carc = CodesCarc.find_by_code(adjustment.carc6)
      row = ["", (carc.description if !carc.blank?), ("$ " + sprintf("%.2f", adjustment.monetary_amount6)) ]
      data.push row
    end
    table data, :width=> 525, :column_widths => [100, 350, 75]
  end


  def build_service_remark(remark)    
    rarc = CodesRarc.find_by_code(remark.remark_code)
    data = [[rarc.description]]
    table data, :width => 525, :column_widths => 525          
  end
  
  
  def header
    canvas do
      bounding_box([bounds.left + 36, bounds.top - 30], :width => bounds.width - 72) do
        cell :content => 'Explaination of Benefits',
             :background_color => '333333',
             :width => bounds.width,
             :height => 30,
             :align => :center,
             :text_color => "FFFFFF",
             :borders => [:bottom],
             :border_width => 2,
             :border_color => '0033CC',
             :padding => 6
      end        
    end
  end
  
  
  def footer
      canvas do
        bounding_box [bounds.left + 36, bounds.bottom + 50], :width  => bounds.width - 72 do
          cell :content => 'P&D Technologies, LLC,  Copyright (c) 2011-2013, All Rights Reserved',
               :background_color => '333333',
               :width => bounds.width,
               :height => 25,
               :align => :center,
               :text_color => "FFFFFF",
               :borders => [:top],
               :border_width => 2,
               :border_color => '0033CC' 
        end        
      end
  end
  
end