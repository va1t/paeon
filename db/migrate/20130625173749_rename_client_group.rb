class RenameClientGroup < ActiveRecord::Migration
  def up
    #drop old indexes
    remove_index :client_groups, :client_id
    remove_index :client_groups, :group_id
     
    #rename columns
    
    #rename table
    rename_table :client_groups, :patients_groups
    
    #add new indexes
    add_index :patients_groups, :client_id
    add_index :patients_groups, :group_id
    
  end

  def down
    #drop new indexes
    remove_index :patients_groups, :client_id
    remove_index :patients_groups, :group_id

    #rename table
    rename_table :patients_groups, :client_groups 
    
    #rename columns
    
    #add old indexes
    add_index :client_groups, :client_id
    add_index :client_groups, :group_id
    
  end
end
