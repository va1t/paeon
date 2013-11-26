class AddInvtoEob < ActiveRecord::Migration
  def up
    add_column :eobs, :invoice_id, :integer
  end

  def down
    remove_column :eobs, :invoice_id
  end
end
