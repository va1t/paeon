class AddToInsBilling < ActiveRecord::Migration
  def up
    remove_column :insurance_billings, :claim_accepted
    remove_column :insurance_billings, :eob_received
  end

  def down
  end
end
