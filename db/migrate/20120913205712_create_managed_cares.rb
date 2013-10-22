class CreateManagedCares < ActiveRecord::Migration
  def change
    create_table :managed_cares do |t|
      t.references :client,           :null => false
      t.references :client_insured
      t.datetime :start_date
      t.datetime :end_date
      t.string   :authorization_id   
      t.integer  :authorized_sessions
      t.integer  :authorized_units,                  :limit => 50
      t.decimal  :authorized_charges, :precision => 15, :scale => 2
      t.integer  :used_sessions
      t.integer  :used_units,                        :limit => 50
      t.decimal  :used_charges, :precision => 15, :scale => 2
      t.decimal  :copay, :precision => 15, :scale => 2
      t.string   :created_user,         :null => false
      t.string   :updated_user
      t.boolean  :deleted,             :null => false, :default => false
      
      t.timestamps
    end
  end
end

