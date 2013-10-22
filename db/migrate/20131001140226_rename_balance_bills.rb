class RenameBalanceBills < ActiveRecord::Migration
  def up
    rename_table :balance_bills, :balance_bill_sessions
    
    rename_column :balance_bill_sessions, :total_invoiced_amount, :total_amount
    rename_column :balance_bill_sessions, :payment_received_amount, :payment_amount
    
    add_column :balance_bill_sessions, :balance_bill_id, :integer
    
    remove_column :balance_bill_sessions, :payment_date
    remove_column :balance_bill_sessions, :closed_date
    remove_column :balance_bill_sessions, :invoice_date
    remove_column :balance_bill_sessions, :invoiced
    remove_column :balance_bill_sessions, :invoice_id
    remove_column :balance_bill_sessions, :status
    
    # balance_bill_details
    rename_column :balance_bill_details, :balance_bill_id, :balance_bill_session_id 
  end

  def down
    rename_column :balance_bill_sessions, :total_amount, :total_invoiced_amount
    rename_column :balance_bill_sessions, :payment_amount, :payment_received_amount
    
    remove_column :balance_bill_sessions, :balance_bill_id
    
    add_column :balance_bill_sessions, :payment_date, :datetime
    add_column :balance_bill_sessions, :closed_date, :datetime
    add_column :balance_bill_sessions, :invoice_date, :datetime
    add_column :balance_bill_sessions, :invoiced, :boolean
    add_column :balance_bill_sessions, :invoice_id, :integer
    add_column :balance_bill_sessions, :status, :integer

    rename_table :balance_bill_sessions, :balance_bills 
    
    # balance_bill_details
    rename_column :balance_bill_details, :balance_bill_session_id, :balance_bill_id     
  end
end
