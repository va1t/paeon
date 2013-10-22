# This migration comes from office_ally_engine (originally 20130709234612)
class Add837p < ActiveRecord::Migration
  def up
    add_column :office_ally837ps, :gs_control_number, :string, :limit => 10
    add_column :office_ally837ps, :transaction_set_control_number, :string, :limit => 10
  end

  def down
    remove_column :office_ally837ps, :gs_control_number
    remove_column :office_ally837ps, :transaction_set_control_number
  end
end
