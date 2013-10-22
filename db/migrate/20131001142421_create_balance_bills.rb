class CreateBalanceBills < ActiveRecord::Migration
  def change
    create_table :balance_bills do |t|
      t.references :patient
      t.integer    :status      
      t.datetime   :invoice_date      
      t.datetime   :closed_date
      t.decimal    :total_amount,   :precision => 15, :scale => 2
      t.decimal    :payment_amount, :precision => 15, :scale => 2
      t.decimal    :balance_owed,   :precision => 15, :scale => 2
      t.boolean    :invoiced,       :default => false
      t.references :invoice

      t.string  :created_user,     :null => false
      t.string  :updated_user
      t.boolean :deleted,          :null => false, :default => false

      t.timestamps
    end
    add_index :balance_bills, :patient_id
  end
end
