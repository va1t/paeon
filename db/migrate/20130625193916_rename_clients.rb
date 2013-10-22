class RenameClients < ActiveRecord::Migration
  def up
    
    # remove old indexes
    remove_index :balance_bills, :client_id
    remove_index :insurance_sessions, :client_id
    remove_index :patient_injuries, :client_id
    remove_index :patients_groups, :client_id
    remove_index :patients_providers, :client_id
    remove_index :clients, :last_name
    
    # rename columns
    rename_column :balance_bills, :client_id, :patient_id
    rename_column :eobs, :client_id, :patient_id
    rename_column :insurance_billings, :client_id, :patient_id
    rename_column :insurance_sessions, :client_id, :patient_id
    rename_column :managed_cares, :client_id, :patient_id
    rename_column :patient_injuries, :client_id, :patient_id
    rename_column :patients_groups, :client_id, :patient_id
    rename_column :patients_providers, :client_id, :patient_id
    rename_column :subscribers, :client_id, :patient_id
    
    # rename tables
    rename_table :clients, :patients
    
    # add new indexes
    add_index :patients, :last_name
    
    add_index :balance_bills, :patient_id
    add_index :insurance_sessions, :patient_id
    add_index :patient_injuries, :patient_id
    add_index :patients_groups, :patient_id
    add_index :patients_providers, :patient_id
    add_index :subscribers, :patient_id
    
    
  end

  def down
    #remove new indexes
    remove_index :patients, :last_name    
    
    remove_index :balance_bills, :patient_id
    remove_index :insurance_sessions, :patient_id
    remove_index :patient_injuries, :patient_id
    remove_index :patients_groups, :patient_id
    remove_index :patients_providers, :patient_id
    remove_index :subscribers, :patient_id
    
    
    #rename table
    rename_table :patients, :clients 
    
    #rename column
    rename_column :balance_bills, :patient_id, :client_id
    rename_column :eobs, :patient_id, :client_id
    rename_column :insurance_billings, :patient_id, :client_id
    rename_column :insurance_sessions, :patient_id, :client_id
    rename_column :managed_cares, :patient_id, :client_id
    rename_column :patient_injuries, :patient_id, :client_id
    rename_column :patients_groups, :patient_id, :client_id
    rename_column :patients_providers, :patient_id, :client_id
    rename_column :subscribers, :patient_id, :client_id

    #add old indexes
    add_index :balance_bills, :client_id
    add_index :insurance_sessions, :client_id
    add_index :patient_injuries, :client_id
    add_index :patients_groups, :client_id
    add_index :patients_providers, :client_id
    add_index :clients, :last_name

  end
end
