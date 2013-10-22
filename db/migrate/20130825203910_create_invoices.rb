class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.references :invoiceable, :polymorphic => true
      t.integer    :status

      t.datetime   :created_date
      t.datetime   :sent_date
      t.datetime   :closed_date

      t.decimal    :total_amount,   :precision => 15, :scale => 2
      t.decimal    :payment_amount, :precision => 15, :scale => 2

      t.string  :created_user,     :null => false
      t.string  :updated_user
      t.boolean :deleted,          :null => false, :default => false

      t.timestamps
    end
    add_index :invoices, [:invoiceable_type, :invoiceable_id]
  end
end
