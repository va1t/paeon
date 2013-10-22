class Renamegrouptherapist < ActiveRecord::Migration
  def up
    remove_index :group_therapists, :column => :group_name
    remove_index :client_groups, :group_therapist_id
    remove_index :group_therapists_therapists, :therapist_id
    remove_index :group_therapists_therapists, :group_therapist_id
    remove_index :insurance_sessions, :group_therapist_id
    
    rename_table :group_therapists, :groups
    rename_table :group_therapists_therapists, :groups_therapists
    
    rename_column :balance_bills, :group_therapist_id, :group_id
    rename_column :client_groups, :group_therapist_id, :group_id
    rename_column :eobs, :group_therapist_id, :group_id
    rename_column :groups_therapists, :group_therapist_id, :group_id
    rename_column :insurance_billings, :group_therapist_id, :group_id
    rename_column :insurance_sessions, :group_therapist_id, :group_id
    
    add_index :groups, :group_name 
    add_index :client_groups, :group_id
    add_index :groups_therapists, :therapist_id
    add_index :groups_therapists, :group_id
    add_index :insurance_sessions, :group_id
  end

  def down
    remove_index :groups, :group_name 
    remove_index :client_groups, :group_id
    remove_index :groups_therapists, :therapist_id
    remove_index :groups_therapists, :group_id
    remove_index :insurance_sessions, :group_id
    
    rename_table :groups_therapists, :group_therapists_therapists
    rename_table :groups, :group_therapists
    
    rename_column :balance_bills, :group_id, :group_therapist_id
    rename_column :client_groups, :group_id, :group_therapist_id
    rename_column :eobs, :group_id, :group_therapist_id
    rename_column :group_therapists_therapists, :group_id, :group_therapist_id
    rename_column :insurance_billings, :group_id, :group_therapist_id
    rename_column :insurance_sessions, :group_id, :group_therapist_id

    add_index :group_therapists, :group_name
    add_index :client_groups, :group_therapist_id
    add_index :group_therapists_therapists, :therapist_id
    add_index :group_therapists_therapists, :group_therapist_id
    add_index :insurance_sessions, :group_therapist_id    
  end
end
