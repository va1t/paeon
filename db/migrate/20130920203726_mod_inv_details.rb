class ModInvDetails < ActiveRecord::Migration
  def up
    rename_column :invoice_details, :type, :record_type
    
  end

  def down
    rename_column :invoice_details, :record_type, :type
  end
end
