class AddtoEobs < ActiveRecord::Migration
  def up
    add_column :eobs, :payment_method, :string, :limit => 10
    add_column :eobs, :bpr_monetary_amount, :decimal, :precision => 15, :scale => 2, :default => 0.0
    add_column :eobs, :trn_payor_identifier, :string, :limit => 20
  end

  def down
    remove_column :eobs, :payment_method
    remove_column :eobs, :bpr_monetary_amount
    remove_column :eobs, :trn_payor_identifier
  end
end
