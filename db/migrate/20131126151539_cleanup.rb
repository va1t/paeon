class Cleanup < ActiveRecord::Migration
  def up
    remove_column :balance_bill_details, :deleted

    remove_column :balance_bill_payments, :deleted
    remove_column :balance_bill_payments, :payment_amount

    remove_column :balance_bill_sessions, :deleted
    remove_column :balance_bill_sessions, :payment_amount

    remove_column :balance_bills, :deleted
    remove_column :balance_bills, :old_status
    remove_column :balance_bills, :invoiced

    remove_column :insurance_billings, :invoiced
    remove_column :insurance_billings, :invoice_id

    remove_column :patients_groups, :invoiced
    remove_column :patients_providers, :invoiced
  end

  def down
    add_column :balance_bill_details, :deleted, :boolean, :default => false

    add_column :balance_bill_payments, :deleted, :boolean, :default => false
    add_column :balance_bill_payments, :payment_amount, :decimal, :precision => 15, :scale => 2

    add_column :balance_bill_sessions, :deleted, :boolean, :default => false
    add_column :balance_bill_sessions, :payment_amount, :decimal, :precision => 15, :scale => 2

    add_column :balance_bills, :deleted, :boolean, :default => false
    add_column :balance_bills, :old_status, :integer
    add_column :balance_bills, :invoiced, :boolean, :default => false

    add_column :insurance_billings, :invoiced, :boolean, :default => false
    add_column :insurance_billings, :invoice_id, :integer

    add_column :patients_groups, :invoiced, :boolean, :default => false
    add_column :patients_providers, :invoiced, :boolean, :default => false

  end
end
