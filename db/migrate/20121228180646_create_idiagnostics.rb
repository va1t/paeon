class CreateIdiagnostics < ActiveRecord::Migration
  def change
    create_table :idiagnostics do |t|
      t.references :idiagable, :polymorphic => true
      t.string     :icd9_code,    :limit => 25
      t.string     :icd10_code,   :limit => 25
      t.string     :dsm_code,     :limit => 25
      t.string     :dsm4_code,    :limit => 25
      t.string     :dsm5_code,    :limit => 25

      t.string     :created_user, :null => false
      t.string     :updated_user
      t.boolean    :deleted,      :null => false, :default => false      

      t.timestamps
    end
    
    add_index :idiagnostics, [:idiagable_type, :idiagable_id]
    
  end
end
