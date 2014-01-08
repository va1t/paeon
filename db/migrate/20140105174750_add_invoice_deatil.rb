class AddInvoiceDeatil < ActiveRecord::Migration
  def up
    add_column :invoice_details, :admin_fee, :boolean, :default => false, :after => :charge_amount
    add_column :invoice_details, :discovery_fee, :boolean, :default => false, :after => :charge_amount
  end

  def down
    add_column :invoice_details, :admin_fee
    add_column :invoice_details, :discovery_fee
  end
end
