class InvoicePaymentVersion < PaperTrail::Version

  #custom table for balance bill versions
  self.table_name = :invoice_payment_versions

end