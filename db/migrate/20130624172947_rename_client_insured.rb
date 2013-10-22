class RenameClientInsured < ActiveRecord::Migration
  def up    
    #remove old indexes
    #n/a
    
    #rename columns
    rename_column :eobs, :client_insured_id, :subscriber_id
    rename_column :insurance_billings, :client_insured_id, :subscriber_id
    rename_column :managed_cares, :client_insured_id, :subscriber_id
    
    #rename tables
    rename_table :client_insureds, :subscribers
    
    #add new indexes
    #na
    
  end

  def down    
    #remove new indexes
    #na
    
    #rename table
    rename_table :subscribers, :client_insureds
     
    #rename columns
    rename_column :eobs, :subscriber_id, :client_insured_id
    rename_column :insurance_billings, :subscriber_id, :client_insured_id
    rename_column :managed_cares, :subscriber_id, :client_insured_id
    
    #add old indexes
    #na
  end
end
