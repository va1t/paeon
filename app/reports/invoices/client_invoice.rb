class ClientInvoice < Prawn::Document
  
  def initialize(params)
    # call the initilize function in prawn::document
    @top_margin = 60
    @bottom_margin = 50
    super(:bottom_margin => @bottom_margin, :top_margin => @top_margin, :page_layout => :landscape)
              
    # set the default font
    font "Helvetica"
    font_size 8
    @title_size = 12
    @large_size = 10

    # pull the appropriate data for the requested invoice    
    @invoice = Invoice.find(params)
    @detail = @invoice.invoice_details
    # estantiate the provider / group with the selector field set
    @object = @invoice.invoiceable_type.classify.constantize.find(@invoice.invoiceable_id)
    @object.selector = @invoice.invoiceable_type == "Provider" ? Selector::PROVIDER : Selector::GROUP
    # get the billing office, or the first office
    @office = @object.offices.where(:billing_location => true).limit(1)
    @office = @object.offices.first if @office.blank?
    # get the system information record
    @system = SystemInfo.first
  end


  def build
    # ensure the header and footer are on every page
    repeat :all do
      header
      footer
    end    
    content
  end


  private

  def content
    # top section - billing center address & invoice number / due date
    section_bottom = bounds.top   #initialize section_bottom
    bounding_box([bounds.left, bounds.top], :width => bounds.width) do
      column_width = bounds.width / 2
      leftbox = bounding_box([bounds.left, bounds.top], :width => column_width) do
        build_billing_center
      end
      section_bottom = leftbox.absolute_bottom      
      rightbox = bounding_box([column_width, bounds.top], :width => column_width) do
        build_invoice_data
      end
      section_bottom = rightbox.absolute_bottom if rightbox.absolute_bottom < section_bottom
    end
    # move the cursor to the lowest of the two bounding boxes
    move_cursor_to section_bottom - @top_margin
    move_down 5

    # middle section - providers address
    section_bottom = bounds.top   #initialize section_bottom
    bounding_box([bounds.left, cursor], :width => bounds.width) do
      column_width = bounds.width / 2
      last_column_width = bounds.width - (2 * column_width)
      leftbox = bounding_box([bounds.left, bounds.top], :width => column_width) do
        build_providers_address
      end
      section_bottom = leftbox.absolute_bottom        
      rightbox = bounding_box([column_width * 2, bounds.top], :width => last_column_width) do
        build_place_holder
      end
      section_bottom = rightbox.absolute_bottom if rightbox.absolute_bottom < section_bottom
    end
    # move the cursor to the lowest of the two bounding boxes
    move_cursor_to section_bottom - @top_margin
    move_down 5
    
    # line item section - listing of the details
    build_detail_line_items    
    move_down 10
    
    # bottom section - subtotals, totals
    build_summary  
  end
  
  
  def build_billing_center
    text @system.organization_name
    indent 20 do
      text @system.address1
      text @system.address2 if !@system.address2.blank?
      text @system.city + ", " + @system.state + "  " + @system.zip
      text @system.work_phone
      text @system.fax_phone       
    end
  end
  
  
  def build_invoice_data
    #pad invoice id with up to 8 zeros
    str = @invoice.id.to_s
    while str.length < 8
      str = "0" + str
    end
    terms = @invoice.payment_terms.blank? ? 30 : @invoice.payment_terms
    termdate = @invoice.created_date + terms.days
    
    text "Invoice #: " + str
    indent 20 do
      text "Payment Terms: " + InvoiceFlow::term(terms)
      text "Payment Due Date: " + termdate.strftime("%m/%d/%Y")  
    end
  end
  
  
  def build_providers_address 
    @name = @object.selector == Selector::PROVIDER ? @object.provider_name : @object.group_name
    text "Bill To:"
    indent 20 do
      text @name
      text @office.address1
      text @office.address2 if !@office.address2.blank?
      text @office.city + ", " + @office.state + "  " + @office.zip
      text ""
      text @office.office_phone
      text @office.office_fax        
    end
  end
  
  
  def build_place_holder
    # nothing happend here.  The provider address is on the left.
    # this is a placeholder if needed.
  end
  
  
  def build_detail_line_items
    # build the data array
    data = [["Client Name", "Provider", "Ins Co", "DOS", "Ins PD", "Other", "Amt Due"]]
    @detail.each do |d|
      case d.record_type
      when InvoiceDetailType::FEE
        data.push ["Monthly Fee", "", d.fee_start.strftime("%m/%d/%y") + " - " + d.fee_end.strftime("%m/%d/%y"),
                  "", "", "", 
                  ("$ " + sprintf("%.2f", d.charge_amount) if !d.charge_amount.blank?)]
      when InvoiceDetailType::SETUP
        data.push [d.patient_name, "", "", 
                   d.dos.strftime("%m/%d/%y"), "", 
                   "New Client", ("$ " + sprintf("%.2f", d.charge_amount) if !d.charge_amount.blank?)]  
      else
        data.push [d.patient_name, "", d.insurance_name, 
                   d.dos.strftime("%m/%d/%y"),
                   ("$ " + sprintf("%.2f", d.ins_paid_amount) if !d.ins_paid_amount.blank?),
                   "", ("$ " + sprintf("%.2f", d.charge_amount) if !d.charge_amount.blank?)]
      end        
    end
    
    # set the table parameters and display  
    table data do |t|
      t.column(0).style :align => :left
      t.column(1).style :align => :left
      t.column(2).style :align => :left
      t.column(3).style :align => :center
      t.column(4).style :align => :center
      t.column(5).style :align => :center
      t.column(6).style :align => :center
      t.row(0).style :background_color => "CCCCCC", :align => :center, :font_style => :bold
      t.column_widths = {0 => 150, 1 => 150, 2 => 150, 3 => 60, 4 => 60, 5 => 60, 6 => 60}
    end
  end
  
  
  def build_summary
    data = [["Summary", "Qty", "Fee", "Amount"]]
    # cob & denied
    if @invoice.count_cob > 0
      data.push ["Coordination of Benefits", @invoice.count_cob,
        ("$ " + sprintf("%.2f", @invoice.cob_fee) if !@invoice.cob_fee.blank?), 
        ("$ " + sprintf("%.2f", @invoice.subtotal_cob) if !@invoice.subtotal_cob.blank?)]
    end
    if @invoice.count_denied > 0
      data.push ["Claims Denied", @invoice.count_denied,
        ("$ " + sprintf("%.2f", @invoice.denied_fee) if !@invoice.denied_fee.blank?), 
        ("$ " + sprintf("%.2f", @invoice.subtotal_denied) if !@invoice.subtotal_denied.blank?)]
    end
    
    # setup fee
    if @invoice.count_setup > 0
      data.push ["New Client Total", 
        @invoice.count_setup, 
        ("$ " + sprintf("%.2f", @invoice.setup_fee) if !@invoice.setup_fee.blank?), 
        ("$ " + sprintf("%.2f", @invoice.subtotal_setup) if !@invoice.subtotal_setup.blank?)]
    end
    
    # if group then break out the number of claims and balance bills by provider
    
    # display claim & balance bill counts by provider, if percentage based also show charges
    
    # if flat fee or dos fee, display the charges. 
    
    table data do |t|
      t.column(0).style :align => :left
      t.column(1).style :align => :center
      t.column(2).style :align => :right
      t.column(3).style :align => :right
      t.row(0).style :background_color => "CCCCCC", :align => :center, :font_style => :bold
      t.column_widths = {0 => 200, 1 => 60, 2 => 60, 3 => 60}
    end
  end
  
  
  def header
    canvas do      
      fill_color "999999"
      text_box "Invoice", :at => [bounds.width / 2, bounds.top - 36], :width => bounds.width / 2, 
               :align => :center, :size => 22
    end
    fill_color "000000"
  end
  
  def footer
      canvas do
        text_box "Make all checks payable to #{@system.organization_name}", :at => [bounds.left + 36, bounds.bottom + 50], :width => bounds.width - 72, :size => 8, :align => :center
        text_box "Thank you for your business!", :at => [bounds.left + 36, bounds.bottom + 40], :width => bounds.width - 72, :style => :bold, :size => 12, :align => :center
        fill_color "333333"  
        text_box "Systems by: P&D Technologies, LLC,  Copyright (c) 2011-2013, All Rights Reserved", :at => [bounds.left + 36, bounds.bottom + 25], :width => bounds.width - 72, :size => 6, :align => :center        
      end
      fill_color "000000"
  end

end