class RemoveFieldsSession < ActiveRecord::Migration
  def up
    remove_column :insurance_sessions, :dataerror
    remove_column :insurance_sessions, :dataerror_count
  end

  def down
    add_column :insurance_sessions, :dataerror, :boolean, :default => false
    add_column :insurance_sessions, :dataerror_count, :integer, :default => 0
  end
end
