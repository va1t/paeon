class CreateIprocedures < ActiveRecord::Migration
  def change
    create_table :iprocedures do |t|
      t.references :iprocedureable, :polymorphic => true      
      t.string     :cpt_code,     :limit => 25
      t.string     :modifier1,    :limit => 10
      t.string     :modifier2,    :limit => 10
      t.string     :modifier3,    :limit => 10
      t.string     :modifier4,    :limit => 10
      t.integer    :rate_id
      t.decimal    :rate_override, :precision => 15, :scale => 2
      t.decimal    :total_charge, :precision => 15, :scale => 2
      t.integer    :units
      t.integer    :sessions

      t.boolean    :diag_pointer1, :default => false
      t.boolean    :diag_pointer2, :default => false
      t.boolean    :diag_pointer3, :default => false
      t.boolean    :diag_pointer4, :default => false
      t.boolean    :diag_pointer5, :default => false
      t.boolean    :diag_pointer6, :default => false
      
      t.string     :created_user, :null => false
      t.string     :updated_user
      t.boolean    :deleted,      :null => false, :default => false      

      t.timestamps
    end
    
    add_index :iprocedures, [:iprocedureable_type, :iprocedureable_id]
    
  end
end



