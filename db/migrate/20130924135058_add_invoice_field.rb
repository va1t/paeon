class AddInvoiceField < ActiveRecord::Migration
  def up
    add_column :insurance_billings, :invoice_id, :integer
    add_column :balance_bills, :invoice_id, :integer
    add_column :patients_providers, :invoice_id, :integer
    add_column :patients_groups, :invoice_id, :integer
  end

  def down
    remove_column :insurance_billings, :invoice_id
    remove_column :balance_bills, :invoice_id
    remove_column :patients_providers, :invoice_id
    remove_column :patients_groups, :invoice_id
  end
  
end
