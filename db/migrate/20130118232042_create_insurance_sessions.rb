class CreateInsuranceSessions < ActiveRecord::Migration
  def change
    create_table :insurance_sessions do |t|
      t.references :client,        :null => false
      t.references :therapist,     :null => false      
      t.references :group_therapist
      t.integer    :selector
      
      t.string     :status,        :limit => 20
      t.references :office
      t.references :billing_office
      t.references :client_history      
      t.references :managed_care      
      t.datetime   :dos,           :null => false      
      t.string     :pos_code,      :limit => 25
      
      t.decimal    :charges_for_service,       :precision => 15, :scale => 2
      t.decimal    :client_copay,              :precision => 15, :scale => 2
      t.decimal    :client_additional_payment, :precision => 15, :scale => 2
      t.decimal    :interest_payment,          :precision => 15, :scale => 2
      t.decimal    :waived_fee,                :precision => 15, :scale => 2
      t.decimal    :balance_owed,              :precision => 15, :scale => 2
      t.boolean    :dataerror,       :default => false
      t.integer    :dataerror_count, :default => 0
            
      t.string     :created_user,    :null => false
      t.string     :updated_user
      t.boolean    :deleted,         :null => false, :default => false

      t.timestamps
    end
    
    add_index :insurance_sessions, :client_id
    add_index :insurance_sessions, :therapist_id
    add_index :insurance_sessions, :group_therapist_id
  end
end



