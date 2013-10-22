class CreateSystemInfos < ActiveRecord::Migration
  def change
    create_table :system_infos do |t|
      t.string :organization_name,  :limit => 100
      t.string :ein_number,         :limit => 20      
      t.string :ssn_number,         :limit => 20      
      t.string :first_name,         :limit => 40
      t.string :last_name,          :limit => 40
      t.string :address1,           :limit => 40
      t.string :address2,           :limit => 40
      t.string :city,               :limit => 20
      t.string :state,              :limit => 15
      t.string :zip,                :limit => 15
      
      t.string :work_phone,         :limit => 20
      t.string :fax_phone,          :limit => 20      
      t.string :email,              :limit => 100
      
      t.string :system_claim_identifier, :limit => 3

      t.string     :created_user,   :null => false
      t.string     :updated_user
      t.boolean    :deleted,        :null => false, :default => false

      t.timestamps
    end
  end
end
