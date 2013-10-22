class CreateNotes < ActiveRecord::Migration
  def change
    create_table :notes do |t|
      t.references :noteable, :polymorphic => true
      t.text :note

      t.string     :created_user, :null => false
      t.string     :updated_user
      t.boolean    :deleted,      :null => false, :default => false
      
      t.timestamps
    end
    
    add_index :notes, [:noteable_type, :noteable_id]
    
  end
end
