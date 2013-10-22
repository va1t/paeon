class CreateGroupTherapists < ActiveRecord::Migration
  def up
    create_table :group_therapists do |t|
      t.string :group_name,     :null => false, :limit => 40
      t.string :web_site
      t.string :office_phone,                   :limit => 20
      t.string :office_fax,                     :limit => 20 
      t.string :ein_number,                     :limit => 20
      t.boolean  :signature_on_file,                           :default => false
      t.datetime :signature_date
      t.string   :license_number,               :limit => 20
      t.datetime :license_date
      t.boolean  :insurance_accepted,                          :default => false
      t.datetime :insurance_date
      t.string   :upin_usin_id,                 :limit => 20
      t.string   :npi,                          :limit =>25
      t.string   :created_user,   :null => false
      t.string   :updated_user
      t.boolean  :deleted,        :null => false, :default => false
      
      t.timestamps
    end
    add_index :group_therapists, :group_name
  end
  
  def down
    remove_index :group_therapists, :column => :group_name
    drop_table :group_therapists
    
  end
end
