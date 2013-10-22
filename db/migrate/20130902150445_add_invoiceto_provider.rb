class AddInvoicetoProvider < ActiveRecord::Migration
  def up
    add_column :providers, :discovery_fee,     :decimal, :precision => 15, :scale => 2, :default => 0.00
    add_column :providers, :admin_fee,         :decimal, :precision => 15, :scale => 2, :default => 0.00
    
    add_column :groups, :discovery_fee,     :decimal, :precision => 15, :scale => 2, :default => 0.00
    add_column :groups, :admin_fee,         :decimal, :precision => 15, :scale => 2, :default => 0.00
  end

  def down
    remove_column :providers, :discovery_fee
    remove_column :providers, :admin_fee
    
    remove_column :groups, :discovery_fee
    remove_column :groups, :admin_fee
  end
end
