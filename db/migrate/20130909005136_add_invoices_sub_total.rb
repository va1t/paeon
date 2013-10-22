class AddInvoicesSubTotal < ActiveRecord::Migration
  def up
    add_column :invoices, :subtotal_claims, :decimal, :precision => 15, :scale => 2, :default => 0.0
    add_column :invoices, :subtotal_balance, :decimal, :precision => 15, :scale => 2, :default => 0.0
    add_column :invoices, :subtotal_setup, :decimal, :precision => 15, :scale => 2, :default => 0.0
    add_column :invoices, :subtotal_cob, :decimal, :precision => 15, :scale => 2, :default => 0.0
    add_column :invoices, :subtotal_denied, :decimal, :precision => 15, :scale => 2, :default => 0.0
    add_column :invoices, :subtotal_admin, :decimal, :precision => 15, :scale => 2, :default => 0.0
    add_column :invoices, :subtotal_discovery, :decimal, :precision => 15, :scale => 2, :default => 0.0
    
    add_column :invoice_details, :description, :string
    add_column :invoice_details, :dos, :datetime
  end

  def down
    remove_column :invoices, :subtotal_claims
    remove_column :invoices, :subtotal_balance
    remove_column :invoices, :subtotal_setup
    remove_column :invoices, :subtotal_cob
    remove_column :invoices, :subtotal_denied
    remove_column :invoices, :subtotal_admin
    remove_column :invoices, :subtotal_discovery

    remove_column :invoice_details, :description
    remove_column :invoice_details, :dos
  end
end
