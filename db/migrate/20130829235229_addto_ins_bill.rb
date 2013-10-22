class AddtoInsBill < ActiveRecord::Migration
  def up
    add_column :insurance_billings, :secondary_status, :integer, :default => 200
  end

  def down
    remove_column :insurance_billings, :secondary_status
  end
end
