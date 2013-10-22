class CreateCodesRarcs < ActiveRecord::Migration
  def change
    create_table :codes_rarcs do |t|
      t.string :code,       :limit => 10
      t.string :description

      t.string  :created_user, :null => false
      t.string  :updated_user
      t.boolean :deleted,      :null => false, :default => false

      t.timestamps
    end
  end
end
