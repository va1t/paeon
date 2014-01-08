class InvoiceVersion < PaperTrail::Version

  #custom table for balance bill versions
  self.table_name = :invoice_versions

end