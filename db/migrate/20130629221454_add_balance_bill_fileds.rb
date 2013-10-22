class AddBalanceBillFileds < ActiveRecord::Migration
  def up
    add_column :balance_bills, :dataerror_count, :integer, :default => 0
    add_column :balance_bills, :dataerror, :boolean, :default => false
  end

  def down
    remove_column :balance_bills, :dataerror_count
    remove_column :balance_bills, :dataerror
  end
end
