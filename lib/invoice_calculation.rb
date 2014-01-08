# this module extends the invoice model
# all calculations are captured in this module
#
# there are three methods for calculating monthly fees to bill the group/provider
#

module InvoiceCalculation

  FLATFEE = 100    # fees are calculated on a flat monthly fee
  DOSFEE  = 200    # fees are calcualted on a daily fee based on date of service
  PERCENT = 300    # fees are calculated on a percentage basis

  METHODS = [["Monthly Flat Fee", FLATFEE], ["DOS Fee", DOSFEE], ["Percentage Based",PERCENT]]

  def self.calculation_method(current_method)
    str = ""
    case current_method
    when FLATFEE
      str = "Monthly Flat Fee"
    when DOSFEE
      str = "DOS Fee"
    when PERCENT
      str = "Percentage"
    end
    return str
  end

  #
  # The calculate family of methods provides the functionality to recalcuate the totals for the invoices.
  # The main calculate method: claculate_invoice provides the looping through the detail records
  # and sums up the subtotals.  Each supporting method returns the total charge for that line item.
  def calculate_invoice
    # all subtotals get initialized to zero
    init_subtotals
    # get the detail records
    @details = self.invoice_details

    # loop through all the details records to calculate the fees
    # if the detail records are marked to include, then calculate the fees
    @details.each do |d|
      if d.disposition == InvoiceDetail::INCLUDE
        case d.record_type
          when InvoiceDetail::CLAIM
            self.subtotal_claims += calculate_claim_percentage(d) if self.invoice_method == PERCENT
            self.total_claim_charge_amount  += d.ins_billed_amount
            self.total_claim_payment_amount += d.ins_paid_amount
          when InvoiceDetail::BALANCE
            self.subtotal_balance += calculate_balance_percentage(d) if self.invoice_method == PERCENT
            self.total_balance_charge_amount  += d.ins_billed_amount
            self.total_balance_payment_amount += d.ins_paid_amount
          when InvoiceDetail::COB
            self.subtotal_cob += calculate_cob_fee(d)
          when InvoiceDetail::DENIED
            self.subtotal_denied += calculate_denied_fee(d)
          when InvoiceDetail::SETUP
            self.subtotal_setup += calculate_patient_setup(d)
        end
        # each detail record has a boolean for admin fee and discovery fee; check each detail record for true
        self.subtotal_discovery += calculate_discovery_fee(d)
        self.subtotal_admin += calculate_admin_fee(d)
      else
        # mark the charge_amount to zero so there is no confusion if it is in the total
        d.charge_amount = 0
      end
    end

    #set the fee_start and fee_end dates for all invoices
    set_fee_dates

    # if flat fee or dos fee, then calculate
    self.subtotal_claims, self.count_flat = calculate_flat_fee if self.invoice_method == FLATFEE
    self.subtotal_claims, self.count_dos = calculate_dos_fee if self.invoice_method == DOSFEE

    # set the total invoice amount
    self.total_invoice_amount = self.subtotal_claims + self.subtotal_balance + self.subtotal_setup
    self.total_invoice_amount += self.subtotal_cob + self.subtotal_denied + self.subtotal_discovery + self.subtotal_admin
    # set the balance owed or waived amount
    if self.invoice_status?(:waived)
      self.waived_amount = self.total_invoice_amount
      self.balance_owed_amount = 0.00
    else
      self.balance_owed_amount = self.total_invoice_amount
      self.waived_amount = 0.00
    end
  end

  def calculate_flat_fee
    # reset the fee_end date to the end of the month
    self.fee_end = self.fee_start.end_of_month

    # get the number of months between the 2 dates.  Dates should mostly be the start and end of the same month. so need to always add 1.
    months = (self.fee_end.year * 12 + self.fee_end.month) - (self.fee_start.year * 12 + self.fee_start.month) + 1
    @details.first.charge_amount = self.flat_fee * months
    return @details.first.charge_amount, months
  end


  def calculate_dos_fee
    # loop through the detail records looking for claims and balance bills
    ary = Array.new
    @details.each do |d|
      ary.push d.dos if (d.record_type == InvoiceDetail::CLAIM || d.record_type == InvoiceDetail::BALANCE) && d.status == InvoiceDetail::INCLUDE
    end
    # pull out the unique dos's
    uniq_ary = ary.uniq{|u| u.dos }
    @details.first.charge_amount = self.dos_fee * uniq_ary.count
    return @details.first.charge_amount, uniq_ary.count
  end


  def set_fee_dates
    # look at past invoices for provider; @object is instantiated in the invoice model when building new invoice
    # when saving the @object needs to be instantiated
    @object = self.invoiceable_type.classify.constantize.find(self.invoiceable_id) if @object.blank?
    @invoice = @object.invoices

    # fill in the fee_start and fee_end dates
    # grab the last invoice and get last dates from that
    last_date = @invoice.last.fee_end  if !@invoice.blank?

   # if the last date is nil then treat it as the first invoice
    if last_date.blank?
      # no invoices, so find the earlest dos in the claims and use the beginning of that month as a starting point.
      date = DateTime.now
      @details.each do |d|
        date = d.dos if (d.record_type == InvoiceDetail::CLAIM || d.record_type == InvoiceDetail::BALANCE) && d.dos < date
      end
      self.fee_start = DateTime.new(date.year, date.month, 1)
    else
      # add one day to the last_date
      self.fee_start = last_date + 1.day
    end
    # set the end date to today's date
    self.fee_end = DateTime.now.strftime("%d/%m/%Y")
  end


  def calculate_claim_percentage(detail)
    detail.charge_amount = detail.ins_paid_amount * (self.claim_percentage / 100)
  end


  def calculate_balance_percentage(detail)
    detail.charge_amount = detail.ins_paid_amount * (self.balance_percentage / 100)
  end


  def calculate_patient_setup(detail)
    detail.charge_amount = self.setup_fee
  end

  def calculate_cob_fee(detail)
    detail.charge_amount = self.cob_fee
  end

  def calculate_denied_fee(detail)
    detail.charge_amount = self.denied_fee
  end

  def calculate_discovery_fee(detail)
    detail.discovery_fee ? self.discovery_fee : 0.0
  end

  def calculate_admin_fee(detail)
    detail.admin_fee ? self.admin_fee : 0.0
  end


  def init_subtotals
    self.total_claim_charge_amount = 0
    self.total_claim_payment_amount = 0
    self.total_balance_charge_amount = 0
    self.total_balance_payment_amount = 0
    self.subtotal_claims = 0
    self.subtotal_balance = 0
    self.subtotal_setup = 0
    self.subtotal_cob = 0
    self.subtotal_denied = 0
    self.subtotal_admin = 0
    self.subtotal_discovery = 0
  end


end