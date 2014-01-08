class AddInvDetail < ActiveRecord::Migration
  def up
    add_column :invoice_details, :description, :string
  end

  def down
    remove_column :invoice_details, :description
  end
end
