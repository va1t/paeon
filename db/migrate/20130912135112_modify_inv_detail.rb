class ModifyInvDetail < ActiveRecord::Migration
  def up
    rename_column :invoice_details, :total_payment_amount, :ins_paid_amount
    rename_column :invoice_details, :total_charge_amount, :ins_billed_amount
    add_column    :invoice_details, :charge_amount, :decimal, :precision => 15, :scale => 2, :default => 0.0
    
    remove_column :invoice_details, :description
    
    add_column :invoice_details, :patient_name, :string, :limit => 80
    add_column :invoice_details, :claim_number, :string, :limit => 50
    add_column :invoice_details, :insurance_name, :string, :limit => 100
  end

  def down
    remove_column :invoice_details, :charge_amount
    rename_column :invoice_details, :ins_paid_amount, :total_payment_amount
    rename_column :invoice_details, :ins_billed_amount, :total_charge_amount
    
    add_column    :invoice_details, :description, :string
    remove_column :invoice_details, :patient_name
    remove_column :invoice_details, :claim_number
    remove_column :invoice_details, :insurance_name
  end
end
