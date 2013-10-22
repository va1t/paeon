class AddErrorToInsBill < ActiveRecord::Migration
  def up
    add_column :insurance_billings, :override_user_id, :string
    add_column :insurance_billings, :override_datetime, :datetime
  end
  
  def down
    remove_column :insurance_billings, :override_user_id
    remove_column :insurance_billings, :override_datetime
  end
end
