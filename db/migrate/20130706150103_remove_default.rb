class RemoveDefault < ActiveRecord::Migration
  def up
    change_column :balance_bills, :status, :integer, :default => nil, :null => true
  end

  def down
    change_column :balance_bills, :status, :integer, :default => 100, :null => false
  end
end
