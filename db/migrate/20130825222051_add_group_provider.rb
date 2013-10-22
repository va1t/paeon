class AddGroupProvider < ActiveRecord::Migration
  def up
    add_column :providers, :invoice_method,     :integer
    add_column :providers, :flat_fee,           :decimal, :precision => 15, :scale => 2, :default => 0.00
    add_column :providers, :dos_fee,            :decimal, :precision => 15, :scale => 2, :default => 0.00
    add_column :providers, :claim_percentage,   :decimal, :precision => 15, :scale => 2, :default => 0.00
    add_column :providers, :balance_percentage, :decimal, :precision => 15, :scale => 2, :default => 0.00
    add_column :providers, :setup_fee,          :decimal, :precision => 15, :scale => 2, :default => 0.00
    add_column :providers, :cob_fee,            :decimal, :precision => 15, :scale => 2, :default => 0.00
    add_column :providers, :denied_fee,         :decimal, :precision => 15, :scale => 2, :default => 0.00
    
    add_column :groups, :invoice_method,     :integer
    add_column :groups, :flat_fee,           :decimal, :precision => 15, :scale => 2, :default => 0.00
    add_column :groups, :dos_fee,            :decimal, :precision => 15, :scale => 2, :default => 0.00
    add_column :groups, :claim_percentage,   :decimal, :precision => 15, :scale => 2, :default => 0.00
    add_column :groups, :balance_percentage, :decimal, :precision => 15, :scale => 2, :default => 0.00
    add_column :groups, :setup_fee,          :decimal, :precision => 15, :scale => 2, :default => 0.00
    add_column :groups, :cob_fee,            :decimal, :precision => 15, :scale => 2, :default => 0.00
    add_column :groups, :denied_fee,         :decimal, :precision => 15, :scale => 2, :default => 0.00
  end

  def down
    remove_column :providers, :invoice_method
    remove_column :providers, :flat_fee
    remove_column :providers, :dos_fee
    remove_column :providers, :claim_percentage
    remove_column :providers, :balance_percentage
    remove_column :providers, :setup_fee
    remove_column :providers, :cob_fee
    remove_column :providers, :denied_fee
    
    remove_column :groups, :invoice_method
    remove_column :groups, :flat_fee
    remove_column :groups, :dos_fee
    remove_column :groups, :claim_percentage
    remove_column :groups, :balance_percentage
    remove_column :groups, :setup_fee
    remove_column :groups, :cob_fee
    remove_column :groups, :denied_fee   
  end
end
