class AddtoInvoices < ActiveRecord::Migration
  def up
    add_column :invoices, :payment_terms, :integer
  end

  def down
    remove_column :invoices, :payment_terms
  end
end
