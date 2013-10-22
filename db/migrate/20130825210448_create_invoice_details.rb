class CreateInvoiceDetails < ActiveRecord::Migration
  def change
    create_table :invoice_details do |t|
      t.references :invoice
      t.references :idetailable, :polymorphic => true
      
      t.boolean :waive,            :default => false
      t.decimal :total_amount,     :precision => 15, :scale => 2

      t.string  :created_user,     :null => false
      t.string  :updated_user
      t.boolean :deleted,          :null => false, :default => false

      t.timestamps
    end
    add_index :invoice_details, :invoice_id
    add_index :invoice_details, [:idetailable_type, :idetailable_id]
  end
end
