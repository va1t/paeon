class CreateEobClaimAdjustments < ActiveRecord::Migration
  def change
    create_table :eob_claim_adjustments do |t|
      t.references :eob
      t.string :claim_adjustment_group_code
      t.string  :carc1,            :limit => 5
      t.decimal :monetary_amount1, :precision => 15, :scale => 2
      t.integer :quantity1

      t.string  :carc2,            :limit => 5
      t.decimal :monetary_amount2, :precision => 15, :scale => 2
      t.integer :quantity2

      t.string  :carc3,            :limit => 5
      t.decimal :monetary_amount3, :precision => 15, :scale => 2
      t.integer :quantity3

      t.string  :carc4,            :limit => 5
      t.decimal :monetary_amount4, :precision => 15, :scale => 2
      t.integer :quantity4

      t.string  :carc5,            :limit => 5
      t.decimal :monetary_amount5, :precision => 15, :scale => 2
      t.integer :quantity5

      t.string  :carc6,            :limit => 5
      t.decimal :monetary_amount6, :precision => 15, :scale => 2
      t.integer :quantity6

      t.string  :created_user, :null => false
      t.string  :updated_user
      t.boolean :deleted,      :null => false, :default => false


      t.timestamps
    end
  end
end
