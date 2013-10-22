class CreateBalanceBillHistories < ActiveRecord::Migration
  def change
    create_table :balance_bill_histories do |t|
      t.references :balance_bill
      t.integer    :status
      t.datetime   :status_date

      t.string     :created_user, :null => false
      t.string     :updated_user
      t.boolean    :deleted,      :null => false, :default => false

      t.timestamps
    end    
  end
end
