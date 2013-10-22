class CreateCodesIcd10 < ActiveRecord::Migration
  def change
    create_table :codes_icd10s do |t|
      t.string  :code,             :null => false, :limit => 25
      t.string  :long_description, :null => false
      t.string  :short_description,                :limit => 100
      
      t.string  :created_user,     :null => false
      t.string  :updated_user
      t.boolean :deleted,          :null => false, :default => false

      t.timestamps
    end
  end
end
