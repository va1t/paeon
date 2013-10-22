class CreateBalanceBillSessions < ActiveRecord::Migration
  def change
    create_table :balance_bill_sessions do |t|
      t.references :insurance_session
      t.references :client
      t.references :group_therapist
      t.references :therapist
      
      t.integer    :status,              :null => false, :default => 100
      t.decimal    :total_invoiced_amount,        :precision => 15, :scale => 2
      t.decimal    :payment_received_amount,      :precision => 15, :scale => 2
      t.datetime   :invoice_date
      t.datetime   :payment_date
      t.datetime   :closed_date

      t.string     :created_user
      t.string     :updated_user
      t.boolean    :deleted,              :null => false, :default => false
    
      t.timestamps
    end
    add_index :balance_bill_sessions, :insurance_session_id
    add_index :balance_bill_sessions, :client_id
  end
end
