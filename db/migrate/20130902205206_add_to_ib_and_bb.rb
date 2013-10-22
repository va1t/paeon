class AddToIbAndBb < ActiveRecord::Migration
  def up
    add_column :insurance_billings, :invoiced, :boolean, :default => false
    add_column :balance_bills, :invoiced, :boolean, :default => false
    add_column :patients_providers, :invoiced, :boolean, :default => false
    add_column :patients_groups, :invoiced, :boolean, :default => false
  end

  def down
    remove_column :insurance_billings, :invoiced
    remove_column :balance_bills, :invoiced
    remove_column :patients_providers, :invoiced
    remove_column :patients_groups, :invoiced
  end
end
