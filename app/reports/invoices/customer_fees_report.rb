class CustomerFeesReport < Prawn::Document

  def initialize
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
    @groups = Group.all(:order => :group_name)
    @providers = Provider.all(:order => [:last_name, :first_name])
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

  def content
    bounding_box [bounds.left, bounds.top], :width => bounds.width do
      group_fees
    end
    move_down 20
    bounding_box [bounds.left, cursor], :width => bounds.width do
      provider_fees
    end
  end

  def group_fees
    text "Group Fees:", :style => :bold, :size => @title_size
    move_down 5
    # push out the group information into a table
    data = [["Name", "Flat Fee", "DOS Fee", "Claim %", "Balance %", "Setup Fee", "Coord Benefits", "Denied Fee", "Discover Fee", "Admin Fee", "Term"]]
    @groups.each do |group|
      data.push [group.group_name,
        "$ " + sprintf("%.2f", group.flat_fee),
        "$ " + sprintf("%.2f", group.dos_fee),
        sprintf("%.2f", group.claim_percentage) + "%",
        sprintf("%.2f", group.balance_percentage)+ "%",
        "$ " + sprintf("%.2f", group.setup_fee),
        "$ " + sprintf("%.2f", group.cob_fee),
        "$ " + sprintf("%.2f", group.denied_fee),
        "$ " + sprintf("%.2f", group.discovery_fee),
        "$ " + sprintf("%.2f", group.admin_fee),
        Invoice::term(group.payment_terms)]
    end
    table data do |t|
      t.row(0).style :background_color => "CCCCCC", :align => :center, :font_style => :bold
      t.column(0).style :align => :left
      t.column_widths = {0 => 120, 1 => 42, 2 => 42, 3 => 42, 4 => 42, 5 => 42, 6 => 42, 7 => 42, 8 => 43, 9 => 42, 10 => 41}
    end
  end

  def provider_fees
    text "Provider Fees:", :style => :bold, :size => @title_size
    move_down 5
    #push out the provier information into a table
    data = [["Name", "Flat Fee", "DOS Fee", "Claim %", "Balance %", "Setup Fee", "Coord Benefits", "Denied Fee", "Discover Fee", "Admin Fee", "Term"]]
    @providers.each do |provider|
      data.push [provider.provider_name,
        "$ " + sprintf("%.2f", provider.flat_fee),
        "$ " + sprintf("%.2f", provider.dos_fee),
        sprintf("%.2f", provider.claim_percentage) + "%",
        sprintf("%.2f", provider.balance_percentage)+ "%",
        "$ " + sprintf("%.2f", provider.setup_fee),
        "$ " + sprintf("%.2f", provider.cob_fee),
        "$ " + sprintf("%.2f", provider.denied_fee),
        "$ " + sprintf("%.2f", provider.discovery_fee),
        "$ " + sprintf("%.2f", provider.admin_fee),
        Invoice::term(provider.payment_terms)]
    end
    table data do |t|
      t.row(0).style :background_color => "CCCCCC", :align => :center, :font_style => :bold
      t.column(0).style :align => :left
      t.column_widths = {0 => 120, 1 => 42, 2 => 42, 3 => 42, 4 => 42, 5 => 42, 6 => 42, 7 => 42, 8 => 43, 9 => 42, 10 => 41}
    end

  end

  def header
    canvas do
      fill_color "999999"
      text_box "Customer Fees Report", :at => [bounds.width / 2, bounds.top - 36], :width => bounds.width / 2,
               :align => :center, :size => 22
    end
    fill_color "000000"
  end


  def footer
      canvas do
        fill_color "333333"
        text_box "Systems by: P&D Technologies, LLC,  Copyright (c) 2011-2013, All Rights Reserved", :at => [bounds.left + 36, bounds.bottom + 25], :width => bounds.width - 72, :size => 6, :align => :center
      end
      fill_color "000000"
  end

end