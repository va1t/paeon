class CreateCodesPos < ActiveRecord::Migration
  def change
    create_table :codes_pos do |t|
      t.string :code,         :limit => 25,      :null => false 
      t.string :description,  :limit => 100
      t.string :created_user,                    :null => false
      t.string :updated_user
      t.boolean :deleted,     :default => false, :null => false

      t.timestamps
    end
  end
end
