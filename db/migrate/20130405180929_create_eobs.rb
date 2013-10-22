class CreateEobs < ActiveRecord::Migration
  def change
    create_table :eobs do |t|
      t.references :insurance_billing
      t.references :therapist
      t.references :group_therapist 

      t.datetime   :eob_date
      t.datetime   :dos
      t.string     :claim_number,                      :limit => 50
      t.string     :group_number,                      :limit => 50
      t.decimal    :charge_amount,                     :precision => 15, :scale => 2
      t.decimal    :payment_amount,                    :precision => 15, :scale => 2
      t.decimal    :subscriber_amount,                 :precision => 15, :scale => 2      
      t.string     :subscriber_first_name,             :limit => 40
      t.string     :subscriber_last_name,              :limit => 40
      t.string     :payor_name,                        :limit => 100
      t.references :insurance_company
      t.integer    :client_id
      t.string     :client_first_name,                 :limit => 40
      t.string     :client_last_name,                  :limit => 40
      t.references :client_insured

      t.datetime   :claim_date
      t.datetime   :service_start_date
      t.datetime   :service_end_date
      t.string     :subscriber_ins_policy,     :limit => 50    
      t.string     :claim_status_code,         :limit => 10
      t.string     :claim_indicator_code,      :limit => 10
    
      t.string     :payor_claim_number,        :limit => 50
      t.string     :payor_contact,             :limit => 100
      t.string     :payor_contact_qualifier,   :limit => 10
    
      t.string     :ref_class_contract,        :limit => 50
      t.string     :ref_authorization_number,  :limit => 50    
    
      t.string     :provider_first_name,       :limit => 40
      t.string     :provider_last_name,        :limit => 40
      t.string     :provider_npi,              :limit => 25
    
      t.string     :payee_name,                :limit => 100
      t.string     :payee_npi,                 :limit => 25
      t.string     :payee_payor_id,            :limit => 75
      t.string     :payee_ein,                 :limit => 20
      t.string     :payee_ssn,                 :limit => 20
      t.string     :payee_address1,            :limit => 40
      t.string     :payee_address2,            :limit => 40
      t.string     :payee_city,                :limit => 20
      t.string     :payee_state,               :limit => 15
      t.string     :payee_zip,                 :limit => 15

      t.integer    :check_number
      t.datetime   :check_date
      t.decimal    :check_amount, :precision => 15, :scale => 2
      t.boolean    :manual,       :default => false
      
      t.string  :created_user, :null => false
      t.string  :updated_user
      t.boolean :deleted,      :null => false, :default => false

      t.timestamps
    end

    add_index :eobs, :eob_date
    add_index :eobs, [:insurance_billing_id, :eob_date]

  end
end
