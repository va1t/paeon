class BalanceBillConsolidated < Prawn::Document

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


# TODO build out the consolidated report

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


  def content

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