class CreateTherapists < ActiveRecord::Migration
  def up
    create_table :therapists do |t|
      t.string :first_name,         :null => false, :limit => 40
      t.string :last_name,          :null => false, :limit => 40
      t.string :therapist_identifier,               :limit => 20
      t.string :ssn_number,                         :limit => 20
      t.string :ein_number,                         :limit => 20      
      t.datetime :dob
      t.boolean  :signature_on_file,                               :default => false
      t.datetime :signature_date
      t.string   :license_number,                   :limit => 20
      t.datetime :license_date
      t.boolean  :insurance_accepted,                              :default => false
      t.datetime :insurance_date
      t.string   :upin_usin_id,                     :limit => 20
      t.string   :office_phone,                     :limit => 20
      t.string   :cell_phone,                       :limit => 20
      t.string   :home_phone,                       :limit => 20 
      t.string   :fax_phone,                        :limit => 20
      t.string   :web_site
      t.string   :npi,                              :limit => 25
      t.string   :email,                            :limit => 75
      t.string   :created_user,     :null => false
      t.string   :updated_user
      t.boolean  :deleted,          :null => false, :default => false
      
      t.timestamps
    end
    add_index :therapists, :last_name
  end
  
  def down
    remove_index :therapists, :column => :last_name
    drop_table :therapists
  end
end
