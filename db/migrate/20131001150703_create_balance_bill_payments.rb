class CreateBalanceBillPayments < ActiveRecord::Migration
  def change
    create_table :balance_bill_payments do |t|
      t.references :balance_bill
      t.decimal    :balance_amount, :precision => 15, :scale => 2
      t.decimal    :payment_amount, :precision => 15, :scale => 2
      
      t.string  :created_user,     :null => false
      t.string  :updated_user
      t.boolean :deleted,          :null => false, :default => false

      t.timestamps
    end
    add_index :balance_bill_payments, :balance_bill_id
  end
end
