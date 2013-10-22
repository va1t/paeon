class RenameClientHistory < ActiveRecord::Migration
  def up
    #remove old indexes
    remove_index :client_histories, :client_id
    
    #rename column
    rename_column :insurance_sessions, :client_history_id, :patient_injury_id
    
    #rename table
    rename_table :client_histories, :patient_injuries
    
    #add new index
    add_index :patient_injuries, :client_id
    
  end

  def down
    #remove new index
    remove_index :patient_injuries, :client_id
    
    #rename table
    rename_table :patient_injuries, :client_histories 
    
    #rename column
    rename_column :insurance_sessions, :patient_injury_id, :client_history_id
    
    #add old index
    add_index :client_histories, :client_id
    
  end
end
