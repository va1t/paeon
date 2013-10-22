class AddInvoices < ActiveRecord::Migration
  def up
    rename_column :invoices, :total_amount, :total_invoice_amount
    rename_column :invoices, :payment_amount, :balance_owed_amount
    
    add_column :invoices, :second_notice_date,    :datetime
    add_column :invoices, :third_notice_date,     :datetime
    add_column :invoices, :deliquent_notice_date, :datetime
    
    add_column :invoices, :total_claim_charge_amount,    :decimal, :precision => 15, :scale => 2, :default => 0.0
    add_column :invoices, :total_claim_payment_amount,   :decimal, :precision => 15, :scale => 2, :default => 0.0
    add_column :invoices, :total_balance_charge_amount,  :decimal, :precision => 15, :scale => 2, :default => 0.0
    add_column :invoices, :total_balance_payment_amount, :decimal, :precision => 15, :scale => 2, :default => 0.0
    add_column :invoices, :count_claims,         :integer, :default => 0
    add_column :invoices, :count_balances,       :integer, :default => 0
    add_column :invoices, :count_cob,            :integer, :default => 0
    add_column :invoices, :count_denied,         :integer, :default => 0
    add_column :invoices, :count_setup,          :integer, :default => 0
    add_column :invoices, :count_admin,          :integer, :default => 0
    add_column :invoices, :count_discovery,      :integer, :default => 0    
    
    # add the fees to the invoice so that the invoice can be verified later
    add_column :invoices, :invoice_method,       :integer
    add_column :invoices, :flat_fee,             :decimal, :precision => 15, :scale => 2, :default => 0.0
    add_column :invoices, :dos_fee,              :decimal, :precision => 15, :scale => 2, :default => 0.0
    add_column :invoices, :claim_percentage,     :decimal, :precision => 15, :scale => 2, :default => 0.0
    add_column :invoices, :balance_percentage,   :decimal, :precision => 15, :scale => 2, :default => 0.0
    add_column :invoices, :cob_fee,              :decimal, :precision => 15, :scale => 2, :default => 0.0
    add_column :invoices, :denied_fee,           :decimal, :precision => 15, :scale => 2, :default => 0.0
    add_column :invoices, :setup_fee,            :decimal, :precision => 15, :scale => 2, :default => 0.0
    add_column :invoices, :admin_fee,            :decimal, :precision => 15, :scale => 2, :default => 0.0
    add_column :invoices, :discovery_fee,        :decimal, :precision => 15, :scale => 2, :default => 0.0
    
    #update the invocie details
    remove_column :invoice_details, :total_amount
    add_column    :invoice_details, :total_payment_amount, :decimal, :precision => 15, :scale => 2, :default => 0.0
    add_column    :invoice_details, :total_charge_amount,  :decimal, :precision => 15, :scale => 2, :default => 0.0
    add_column    :invoice_details, :status, :integer
  end

  def down
    rename_column :invoices, :total_invoice_amount, :total_amount
    rename_column :invoices, :balance_owed_amount, :payment_amount 

    remove_column :invoices, :second_notice_date
    remove_column :invoices, :third_notice_date
    remove_column :invoices, :deliquent_notice_date

    remove_column :invoices, :total_claim_charge_amount
    remove_column :invoices, :total_claim_payment_amount
    remove_column :invoices, :total_balance_charge_amount
    remove_column :invoices, :total_balance_payment_amount
    remove_column :invoices, :count_claims
    remove_column :invoices, :count_balances
    remove_column :invoices, :count_cob
    remove_column :invoices, :count_denied
    remove_column :invoices, :count_setup
    remove_column :invoices, :count_admin
    remove_column :invoices, :count_discovery
    
    # add the fees to the invoice so that the invoice can be verified later
    remove_column :invoices, :invoice_method
    remove_column :invoices, :flat_fee
    remove_column :invoices, :dos_fee
    remove_column :invoices, :claim_percentage
    remove_column :invoices, :balance_percentage
    remove_column :invoices, :cob_fee
    remove_column :invoices, :denied_fee
    remove_column :invoices, :setup_fee
    remove_column :invoices, :admin_fee
    remove_column :invoices, :discovery_fee
    
    add_column    :invoice_details, :total_amount, :decimal, :precision => 15, :scale => 2, :default => 0.0
    remove_column :invoice_details, :total_payment_amount
    remove_column :invoice_details, :total_charge_amount
    remove_column :invoice_details, :status
  end
end
