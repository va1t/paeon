class CleanupEobDetail < ActiveRecord::Migration
  def up
    remove_column :eob_details, :remarks_code
  end

  def down
    add_column :eob_details, :remarks_code, :string
  end
end
