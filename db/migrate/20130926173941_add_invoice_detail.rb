class AddInvoiceDetail < ActiveRecord::Migration
  def up
    add_column :invoice_details, :provider_name, :string, :limit => 90  # make larger for the ", " characters
    add_column :invoices, :count_dos,  :integer, :default => 0
    add_column :invoices, :count_flat, :integer, :default => 0
  end

  def down
    remove_column :invoice_details, :provider_name 
    remove_column :invoices, :count_dos
    remove_column :invoices, :count_flat
  end
end
