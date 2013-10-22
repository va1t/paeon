class ModiBalanceBill2 < ActiveRecord::Migration
  def up
    add_column :balance_bills, :dataerror_count, :integer, :default => 0
    add_column :balance_bills, :dataerror, :boolean, :default => false
    add_column :balance_bills, :provider_id, :integer
    add_column :balance_bills, :comment, :string
    
    remove_column :balance_bill_sessions, :dataerror_count
    remove_column :balance_bill_sessions, :dataerror
  end

  def down
    remove_column :balance_bills, :dataerror_count
    remove_column :balance_bills, :dataerror
    remove_column :balance_bills, :provider_id
    remove_column :balance_bills, :comment
    
    add_column :balance_bill_sessions, :dataerror_count, :integer, :default => 0
    add_column :balance_bill_sessions, :dataerror, :boolean, :default => false
  end
end
