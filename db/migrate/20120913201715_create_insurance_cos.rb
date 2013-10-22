class CreateInsuranceCos < ActiveRecord::Migration
  def change
    create_table :insurance_companies do |t|
      t.string :name,               :null => false, :limit => 100
      t.string :address1,                           :limit => 40
      t.string :address2,                           :limit => 40
      t.string :city,                               :limit => 20
      t.string :state,                              :limit => 15
      t.string :zip,                                :limit => 15
      t.string :main_phone,                         :limit => 20
      t.string :main_phone_description,             :limit => 50
      t.string :alt_phone,                          :limit => 20
      t.string :alt_phone_description,              :limit => 50
      t.string :fax_number,                         :limit => 20
      t.string :insurance_co_id,                    :limit => 100
      t.string :submitter_id,                       :limit => 100     
      
      t.string :created_user,       :null => false
      t.string :updated_user
      t.boolean :deleted,           :null => false, :default => false
      
      t.timestamps
    end
  end
end
