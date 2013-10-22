class RenameTherapist < ActiveRecord::Migration  
  def up
    #drop old indexes
    remove_index :client_therapists, :therapist_id
    remove_index :groups_therapists, :therapist_id
    remove_index :insurance_sessions, :therapist_id
    remove_index :therapists, :last_name
    
    #rename columns
    rename_column :balance_bills, :therapist_id, :provider_id
    rename_column :client_therapists, :therapist_id, :provider_id
    rename_column :eob_details, :therapist_id, :provider_id
    rename_column :eobs, :therapist_id, :provider_id
    rename_column :groups_therapists, :therapist_id, :provider_id
    rename_column :insurance_billings, :therapist_id, :provider_id
    rename_column :insurance_sessions, :therapist_id, :provider_id
    
    rename_column :therapists, :therapist_identifier, :provider_identifier
    
    #rename tables
    rename_table :therapists, :providers
    rename_table :groups_therapists, :groups_providers
    rename_table :client_therapists, :clients_providers
    
    #add new indexes
    add_index :clients_providers, :provider_id
    add_index :groups_providers, :provider_id
    add_index :insurance_sessions, :provider_id
    add_index :providers, :last_name
    
  end

  def down
    #drop new indexes
    remove_index :clients_providers, :provider_id
    remove_index :groups_providers, :provider_id
    remove_index :insurance_sessions, :provider_id
    remove_index :providers, :last_name
    
    #rename tables
    rename_table :providers, :therapists 
    rename_table :groups_providers, :groups_therapists
    rename_table :clients_providers, :client_therapists 
    
    #rename columns
    rename_column :balance_bills, :provider_id, :therapist_id
    rename_column :client_therapists, :provider_id, :therapist_id
    rename_column :eob_details, :provider_id, :therapist_id
    rename_column :eobs, :provider_id, :therapist_id
    rename_column :groups_therapists, :provider_id, :therapist_id
    rename_column :insurance_billings, :provider_id, :therapist_id
    rename_column :insurance_sessions, :provider_id, :therapist_id
    
    rename_column :therapists, :provider_identifier, :therapist_identifier
    
    #add old indexes
    add_index :client_therapists, :therapist_id
    add_index :groups_therapists, :therapist_id
    add_index :insurance_sessions, :therapist_id
    add_index :therapists, :last_name
  end
end
