class AddPaymentTerms < ActiveRecord::Migration
  def up
    add_column :groups,    :payment_terms, :integer
    add_column :providers, :payment_terms, :integer
    
    remove_column :invoice_details, :waive
    rename_column :invoice_details, :status, :type
    add_column    :invoice_details, :status, :integer
  end

  def down
    remove_column :groups,    :payment_terms
    remove_column :providers, :payment_terms

    add_column :invoice_details, :waive, :boolean, :default => false
    remove_column :invoice_details, :status
    rename_column :invoice_details, :type, :status
  end
end
