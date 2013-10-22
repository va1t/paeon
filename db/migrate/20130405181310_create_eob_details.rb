class CreateEobDetails < ActiveRecord::Migration
  def change
    create_table :eob_details do |t|
      t.references :eob
      t.datetime   :dos
      t.references :therapist
      t.string     :provider_name,   :limit => 75
      t.string     :type_of_service, :limit => 75
      t.decimal    :charge_amount,                    :precision => 15, :scale => 2
      t.decimal    :allowed_amount,                   :precision => 15, :scale => 2
      t.decimal    :copay_amount,                     :precision => 15, :scale => 2
      t.decimal    :deductible_amount,                :precision => 15, :scale => 2
      t.decimal    :other_carrier_amount,             :precision => 15, :scale => 2
      t.decimal    :not_covered_amount,               :precision => 15, :scale => 2
      t.decimal    :payment_amount,                   :precision => 15, :scale => 2
      t.decimal    :subscriber_amount,                :precision => 15, :scale => 2
    
      t.integer    :units
      t.datetime   :service_start
      t.datetime   :service_end
    
      t.string     :claim_number,              :limit => 50
      t.string     :ref_authorization_number,  :limit => 50
      t.string     :ref_prior_authorization,   :limit => 50
      t.string     :remarks_code,              :limit => 10

      t.string     :created_user, :null => false
      t.string     :updated_user
      t.boolean    :deleted,      :null => false, :default => false

      t.timestamps
    end
    
    add_index :eob_details, [:id, :dos, :type_of_service]
    
  end
end
