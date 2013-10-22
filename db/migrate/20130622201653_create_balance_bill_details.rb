class CreateBalanceBillDetails < ActiveRecord::Migration
  def change
    create_table :balance_bill_details do |t|
      t.references :balance_bill, :null => false
      t.string     :description
      t.decimal    :amount,       :precision => 15, :scale => 2
      t.integer    :quantity
      
      t.string     :created_user, :null => false
      t.string     :updated_user
      t.boolean    :deleted,      :null => false, :default => false

      t.timestamps
    end
    add_index :balance_bill_details, :balance_bill_id
  end
end
