class InvoiceDetailVersion < PaperTrail::Version

  #custom table for balance bill versions
  self.table_name = :invoice_detail_versions

end