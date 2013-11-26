class BalanceBillInvoice < Prawn::Document

  def initialize(params)
    # call the initilize function in prawn::document
    @top_margin = 60
    @bottom_margin = 50
    super(:bottom_margin => @bottom_margin, :top_margin => @top_margin)

    # set the default font
    font "Helvetica"
    font_size 8
    @title_size = 12
    @large_size = 10

    # pull the appropriate data for the request into an array of balance bills
    @balance_bill = BalanceBill.includes(:patient, :balance_bill_payments, :balance_bill_sessions => [:insurance_session, :provider]).find(params)
    @patient = @balance_bill.patient

    # use the first balance_bill_session provider id
    @balance_bill_session = @balance_bill.balance_bill_sessions.first
    @provider = @balance_bill_session.provider
    @session = @balance_bill_session.insurance_session
    @provider_office = @session.office
    @system = SystemInfo.first
  end


  def build
      # ensure the header and footer are on every page, even if the balance bill spans multiple pages
      repeat :all do
        header
        footer
      end
      content
  end


  private

  # content will loop through the array of balance bills and produce a single invoice
  def content
    # the header above this box contains the logo and the word statement
    # this bounding box contains the compny name and the statement info
    section_bottom = bounds.top   #initialize section_bottom
    bounding_box [bounds.left, bounds.top], :width => bounds.width do
      stroke_horizontal_rule
      leftbox = bounding_box [bounds.left, bounds.top - 5], :width => bounds.width / 2 do
        get_provider_name
        #get_company_name            #company name
      end
      rightbox = bounding_box [bounds.width / 2, bounds.top - 5], :width => bounds.width / 2 do
        get_statement_information   #statment information
      end
    end
    move_down 70
    # this bounding box contains the bill to address and any comments
    bounding_box [bounds.left, cursor], :width => bounds.width do
      stroke_horizontal_rule
      bounding_box [bounds.left, bounds.top - 10], :width => bounds.width / 2 do
        get_bill_to_address       # bill to address
      end
      bounding_box [bounds.width / 2, bounds.top - 10], :width => bounds.width / 2 do
        get_comments              # comments
      end
    end
    # details balance billing section
    move_down 60
    stroke_horizontal_rule
    get_details
    get_detail_summary
    get_remittance
  end


  def get_provider_name
    text @provider.first_name + " " + @provider.last_name, :style => :bold, :size => @title_size

    indent 10 do
      text @provider_office.address1
      text @provider_office.address2  if !@provider_office.address2.blank?
      text @provider_office.city + ", " + @provider_office.state + "   " + @provider_office.zip
      text "Office: " + (@provider.office_phone.blank? ? "" : @provider.office_phone)
      text "Fax: " + (@provider.fax_phone.blank? ? "" : @provider.fax_phone)
    end
  end


  def get_company_name
    if !@system.organization_name.blank?
      text @system.organization_name, :style => :bold, :size => @title_size
    end
    indent 10 do
      text @system.address1
      text @system.address2  if !@system.address2.blank?
      text @system.city + ", " + @system.state + "   " + @system.zip
      text "Office: " + @system.work_phone
      text "Fax: " + @system.fax_phone
    end
  end


  def get_statement_information
    text_box "Date: ", :at => [bounds.left, bounds.top - 20], :style => :bold
    date = @balance_bill.invoice_date.blank? ? DateTime.now.strftime("%m/%d/%Y") : @balance_bill.invoice_date.strftime("%m/%d/%Y")
    text_box date, :at => [bounds.left + 75, bounds.top - 20]
    text_box "Statement: #", :at => [bounds.left, bounds.top - 30], :style => :bold
    text_box @balance_bill.id.to_s, :at => [bounds.left + 75, bounds.top - 30]
    text_box "Customer ID:", :at => [bounds.left, bounds.top - 40], :style => :bold
    text_box @balance_bill.patient_id.to_s, :at => [bounds.left + 75, bounds.top - 40]
  end


  def get_bill_to_address
    text "Bill To:", :style => :bold, :size => @large_size
    indent 10 do
      text @patient.patient_name, :style => :bold
      text @patient.address1
      text @patient.address2 if !@patient.address2.blank?
      text @patient.city + ", " + @patient.state + "   " + @patient.zip
    end
  end


  def get_comments
    text "Comments:", :style => :bold, :size => @large_size
    indent 10 do
      comment = @balance_bill.comment.blank? ? "" : @balance_bill.comment
      text_box comment, :at => [bounds.left, bounds.top - 10], :width => bounds.width
    end
  end


  def get_details
    # print header for details
    data = [["Date", "Description","Quantity", "Amount"]]

    # print out the session records
    @balance_bill.balance_bill_sessions.each do |bb_entry|
      dos = bb_entry.dos ? bb_entry.dos.strftime("%m/%d/%y") : " "
      # print the waived sessions
      if bb_entry.disposition == BalanceBillSession::WAIVE && !bb_entry.status?(:deleted)
        waived_comment = "Fee $" + sprintf("%.2f", bb_entry.total_amount) + "waived for DOS"
        data.push [dos, waived_comment, "", ""]
      end

      # print the included sessions
      if bb_entry.disposition == BalanceBillSession::INCLUDE && !bb_entry.status?(:deleted)
        bb_entry.balance_bill_details.each do |detail|
          data.push [dos, detail.description, detail.quantity, "$ " + sprintf("%.2f", detail.amount) ] if !detail.status?(:deleted)
        end
      end
    end

    # push 1 extra blank row
    data.push [" ", "", "", ""]

    # print out the payments
    @balance_bill.balance_bill_payments.each do |bb_payment|
      payment_date = bb_payment.payment_date ? bb_payment.payment_date.strftime("%m/%d/%y") : " "
      payment_text = "Payment received"
      payment_text += (": Check #: " + bb_payment.check_number) if !bb_payment.check_number.blank?
      data.push [payment_date, payment_text, "", "$ " + sprintf("%.2f", bb_payment.payment_amount)]
    end

    # publish the data array to the table
    table data do |t|
        t.row(0).style :background_color => "CCCCCC", :align => :center, :font_style => :bold
        t.column_widths = {0 => 75, 1 => 315, 2 => 75, 3 => 75}
        t.column(0).style :align => :center
        t.column(2).style :align => :center
        t.column(3).style :align => :center
    end
  end


  def get_detail_summary
    data = [["Sub Total", "Paid", "30 Days Past Due", "60 Days Past Due", "90 Days Past Due", "Amount Due"]]
    data.push ["$ " + sprintf("%.2f", @balance_bill.total_amount),
               "$ " + sprintf("%.2f", @balance_bill.payment_amount),
               "",
               "",
               "",
               "$ " + sprintf("%.2f", @balance_bill.balance_owed)]
    table data do |t|
      t.row(0).style :background_color => "CCCCCC", :align => :center, :font_style => :bold
      t.column_widths = {0 => 90, 1 => 90, 2 => 90, 3 => 90, 4 => 90, 5 => 90}
      t.cells.style :align => :center
    end
  end


  def get_remittance
    move_down 10
    data = [["Remittance", " "],
            ["Statement #:", @balance_bill.id.to_s],
            ["Date", " "],
            ["Amount Due:", "$ " + sprintf("%.2f", @balance_bill.balance_owed)],
            ["Amount Enclosed", " "]]
    table data do |t|
      t.row(0).style :background_color => "CCCCCC", :align => :center, :font_style => :bold
      t.column(0).style :align => :left
      t.column_widths = {0 => 75, 1 => 150}
    end
  end


  def header
    canvas do
      fill_color "999999"
      text_box "Statement", :at => [bounds.width / 2, bounds.top - 36], :width => bounds.width / 2,
               :align => :center, :size => 22
    end
    fill_color "000000"
  end


  def footer
      canvas do
        text_box "Make all checks payable to #{@provider.first_name} #{@provider.last_name}", :at => [bounds.left + 36, bounds.bottom + 50], :width => bounds.width - 72, :size => 8, :align => :center
        text_box "Thank you for your business!", :at => [bounds.left + 36, bounds.bottom + 40], :width => bounds.width - 72, :style => :bold, :size => 12, :align => :center
        fill_color "333333"
        text_box "Systems by: P&D Technologies, LLC,  Copyright (c) 2011-2013, All Rights Reserved", :at => [bounds.left + 36, bounds.bottom + 25], :width => bounds.width - 72, :size => 6, :align => :center
      end
      fill_color "000000"
  end

end