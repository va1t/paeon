class ChangeSessionStatus < ActiveRecord::Migration
  def up
    rename_column :insurance_sessions, :status, :old_status
    add_column :insurance_sessions, :status, :integer
  end

  def down
    remove_column :insurance_sessions, :status
    rename_column :insurance_sessions, :old_status, :status 
  end
end
