class CreateClients < ActiveRecord::Migration
  def up
    create_table :clients do |t|
      t.string :first_name,         :null => false, :limit => 40
      t.string :last_name,          :null => false, :limit => 40
      t.string :address1,                           :limit => 40
      t.string :address2,                           :limit => 40
      t.string :city,                               :limit => 20
      t.string :state,                              :limit => 15
      t.string :zip,                                :limit => 15
      t.string :home_phone,                         :limit => 20
      t.string :work_phone,                         :limit => 20
      t.string :cell_phone,                         :limit => 20
      t.string :ssn_number,                         :limit => 20
      t.string :gender,                             :limit => 10      
      t.datetime :dob
      t.string :relationship_status
      t.string :pos_code,                           :limit => 25      
      t.string :referred_to,                        :limit => 50
      t.string :referred_to_type,                   :limit => 50
      t.string :referred_from,                      :limit => 50
      t.string :referred_from_type,                 :limit => 50
      t.string :referred_from_npi,                  :limit => 25
      t.boolean :assignment_benefits, :default => false
      t.boolean :accept_assignment,   :default => false
      t.boolean :signature_on_file,   :default => false
      t.string  :patient_status,      :limit => 50
      
      t.string :created_user,       :null => false
      t.string :updated_user
      t.boolean :deleted,           :null => false, :default => false
      
      t.timestamps
    end
    add_index :clients, :last_name
  end
  
  def down
    remove_index :clients, :column => :last_name
    drop_table :clients
  end
end
