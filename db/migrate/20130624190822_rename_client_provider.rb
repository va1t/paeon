class RenameClientProvider < ActiveRecord::Migration
  def up
    #remove old indexes    
    remove_index :clients_providers, :provider_id

    #rename_columns

    #rename tables
    rename_table :clients_providers, :patients_providers
    
    #add new indexes
    add_index :patients_providers, :client_id
    add_index :patients_providers, :provider_id

  end

  def down
    #remove new indexes
    remove_index :patients_providers, :client_id
    remove_index :patients_providers, :provider_id

    #rename tables
    rename_table :patients_providers, :clients_providers 
    
    #rename columns

    #add old indexes
    add_index :clients_providers, :client_id
    add_index :clients_providers, :provider_id

  end
end
