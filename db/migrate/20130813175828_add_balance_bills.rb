class AddBalanceBills < ActiveRecord::Migration
  def up
    add_column :balance_bills, :dos, :datetime
  end

  def down
    remove_column :balance_bills, :dos
  end
end
