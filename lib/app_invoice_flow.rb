# both the InvoiceFlow and InvoiceDetailType classes are defined in this file


class InvoiceFlow
  
  # invoiceflow constants, made it part of a class so it is clear that the constants are workflow related.
  
  # group / provider invoice status
  INITIATE        = 100     # initial state for an invoice
  READY           = 200     # invoice is ready for submitting to provider
  INVOICED        = 300     # invoice submitted to provider   
  ACKNOWLEDGED    = 400     # invoice received by provicer
  PAID            = 500     # invoice payment received
  LATE            = 600     # invoice is 30 days late
  COLLECTIONS     = 700     # invocie is sent to collections
  ERRORS          = 800     # invoice manually set to errors
  CLOSED          = 900     # claim closed; either balance billed, balance zeroed or secondary claim submitted
  CANCELED        = 950     # invocie was cancelled
  
  # payment terms for invoices
  # defining the majority fo the terms so that the numbering sequence is established
  NET10 = 10
  NET15 = 15
  NET20 = 20
  NET30 = 30
  NET45 = 45
  NET50 = 50
  NET60 = 60
  NET75 = 75
  NET90 = 90
  
  # constant array is utilized in populating the dropdown selects for payment terms
  PAYMENT_TERMS = [["Net 20", NET20], ["Net 30", NET30], ["Net 45", NET45], ["Net 60", NET60]]

  def self.status(current_status)
    case current_status
    when READY
      str = "Ready"
    when INVOICED
      str = "Invoiced"
    when ACKNOWLEDGED
      str = "Acknowledged"
    when ERRORS
      str = "Errors"
    when PAID
      str = "Paid"
    when LATE
      str = "Late Payment"
    when COLLECTIONS
      str = "Collections"
    when CLOSED
      str = "Closed"
    when CANCELED
      str = "Canceled"
    else #assume when the status is unknown, default to INITIATE
      str = "Initiated"
    end
    return str    
  end

  #
  # used to determine if the invoice is still in the initiate or ready state
  # in the initate and ready state, the user can change fields 
  def self.editable_state?(status)
    status <= READY || (status == ERRORS )
  end


  #
  # used to determine if the associated record is editable according to the invoice flow rules
  #
  def self.deletable?(status)
    return status >= READY ? false : true    
  end
    
    
  def self.term(payment_term)
    case payment_term
      when NET10
        str = "Net 10"
      when NET15
        str = "Net 15"
      when NET20
        str = "Net 20"
      when NET30
        str = "Net 30"
      when NET45
        str = "Net 45"
      when NET50
        str = "Net 50"
      when NET60
        str = "Net 60"
      when NET75
        str = "Net 75"
      when NET90
        str = "Net 90"
      else
        str = "N/A"
    end
    return str
  end

end


# defines the type of detailed record
# these values are utilized within the invoice_detail status field
class InvoiceDetailType
  
  # these are the types of invoice detail records we can have
  FEE       = 100     # detail is a fee based calculation
  CLAIM     = 200     # detail is a claim
  BALANCE   = 300     # balance bill record
  COB       = 400     # coordination of benefits fee
  DENIED    = 500     # claim denied fee
  SETUP     = 600     # new client setup fee
  DISCOVERY = 700     # discovery fee
  ADMIN     = 800     # admin fee
  ADHOC     = 900     # the detailed record is an ad hoc record added to the invoice
  
  
  # status of the invoice detail
  INCLUDE = 100  # default - include the charge onthe invoice
  WAIVE   = 200  # do not include this record on an invoice.
  SKIP    = 300  # skip this invoice detail record on the invoice, but allow it to appear on a future invoice
  
  
  def self.type(current_type)
    case current_type
    when FEE
      str = "Fee Based Charge"
    when CLAIM
      str = "Claim"
    when BALANCE
      str = "Balance Bill"
    when COB
      str = "Coord Benefits"
    when DENIED
      str = "Claim Denied"
    when SETUP
      str = "Patient Setup"
    when DISCOVERY
      str = "Discovery"
    when ADMIN
      str = "Administrative"
    else
      str ="Ad Hoc"
    end
    return str
  end
  
  
  def self.status(current_status)
    case current_status
    when INCLUDE
      str = "Included"
    when WAIVE
      str = "Waived"
    else SKIP
      str = "Skipped"
    end
    return str
  end
  
end