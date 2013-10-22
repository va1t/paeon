class RemoveSubscriberField < ActiveRecord::Migration
  def up
    remove_column :subscribers, :managed_care    
  end

  def down
    add_column :subscribers, :managed_care, :boolean
  end
end
