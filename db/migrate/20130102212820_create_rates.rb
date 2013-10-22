class CreateRates < ActiveRecord::Migration
  def change
    create_table :rates do |t|
      t.references :rateable, :polymorphic => true
      t.string     :description
      t.decimal    :rate,         :default => 0.0, :precision => 15, :scale => 2
      t.string     :cpt_code,     :limit => 25
      
      t.string     :created_user, :null => false
      t.string     :updated_user
      t.boolean    :deleted,      :null => false, :default => false
      t.timestamps
    end
    
    add_index :rates, [:rateable_type, :rateable_id]
    
  end
end
