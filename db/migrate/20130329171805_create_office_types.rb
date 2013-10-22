class CreateOfficeTypes < ActiveRecord::Migration
  def change
    create_table :office_types do |t|
      t.string  :name,         :null => false, :limit => 50
      t.boolean :perm,                         :default => false
      t.string  :created_user, :null => false
      t.string  :updated_user
      t.boolean :deleted,      :null => false, :default => false


      t.timestamps
    end
  end
end
