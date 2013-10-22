class CreateDataerrors < ActiveRecord::Migration
  def change
    create_table :dataerrors do |t|
      t.references :dataerrorable, :polymorphic => true
      t.string :message
      
      t.string     :created_user, :null => false
      t.string     :updated_user
      t.boolean    :deleted,      :null => false, :default => false

      t.timestamps
    end
    add_index :dataerrors, [:dataerrorable_type, :dataerrorable_id]
  end
end
