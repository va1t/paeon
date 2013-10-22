class CreateInsuranceBillings < ActiveRecord::Migration
  def change
    create_table :insurance_billings do |t|
      t.references :insurance_session, :null => false
      t.references :client_insured
      t.references :client
      t.references :therapist
      t.references :group_therapist
      t.references :insurance_company
      
      t.datetime   :dos
      t.integer    :status
      t.decimal    :insurance_billed,    :precision => 15, :scale => 2
      t.string     :claim_number,        :limit => 50      
      t.datetime   :claim_submitted
      t.datetime   :claim_accepted
      t.datetime   :eob_received    
      t.integer    :dataerror_count,     :default => 0
      t.boolean    :dataerror,           :default => false
      
      t.string     :created_user,        :null => false
      t.string     :updated_user
      t.boolean    :deleted,             :null => false, :default => false
      
      t.timestamps
    end
    add_index :insurance_billings, :insurance_session_id
  end
end
