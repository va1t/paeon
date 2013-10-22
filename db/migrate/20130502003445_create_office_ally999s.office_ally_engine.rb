# This migration comes from office_ally_engine (originally 20130429020507)
class CreateOfficeAlly999s < ActiveRecord::Migration
  def change
    create_table :office_ally999s do |t|
      t.references :office_ally_file_receive
      
      t.string     :ak1_gs_control_number, :limit => 10
      t.integer    :ak2_count
      t.string     :ak2_transaction_set_identifier, :limit => 5
      t.string     :ak2_transaction_set_control_number, :limit => 10
      t.integer    :ik3_error_count, :default => 0
      t.string     :ik5_transaction_set_acknoledgment_code, :limit => 5
      t.string     :ak9_gs_acknowledgment_code, :limit => 5
      t.integer    :ak9_st_sets_included
      t.integer    :ak9_st_sets_received
      t.integer    :ak9_st_sets_accepted
      
      t.timestamps
    end
  end
end
