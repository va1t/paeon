class CreateCodesDsms < ActiveRecord::Migration
  def change
    create_table :codes_dsms do |t|
      t.string :version,          :null => false, :limit => 10
      t.string :code,             :null => false, :limit => 25
      t.string :long_description, :null => false
      t.string :short_description,                :limit => 100
      t.string :category,                         :limit => 75
      t.string  :created_user,    :null => false
      t.string  :updated_user
      t.boolean :deleted,         :null => false, :default => false

      t.timestamps
    end
  end
end
