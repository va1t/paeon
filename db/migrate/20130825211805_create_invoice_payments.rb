class CreateInvoicePayments < ActiveRecord::Migration
  def change
    create_table :invoice_payments do |t|
      t.references :invoice
      t.decimal    :payment_amount, :precision => 15, :scale => 2
      t.datetime   :payment_date
      t.decimal    :balance_amount, :precision => 15, :scale => 2

      t.string  :created_user,     :null => false
      t.string  :updated_user
      t.boolean :deleted,          :null => false, :default => false

      t.timestamps
    end
    add_index :invoice_payments, :invoice_id
  end
end
