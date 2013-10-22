# This migration comes from office_ally_engine (originally 20130429023500)
class CreateOfficeAlly835s < ActiveRecord::Migration
  def change
    create_table :office_ally835s do |t|
      t.references :office_ally_file_receive
      
      t.string     :bpr_transaction_handling_code, :limit => 5
      t.decimal    :bpr_monetary_amount, :precision => 15, :scale => 2
      t.string     :bpr_payment_method_code, :limit => 5
      t.datetime   :bpr_date_check
      
      t.string     :trn_check_number, :limit => 50
      t.string     :trn_payer_identifier, :limit => 20
      
      t.integer    :clm_count
      t.string     :clm_claim_number, :limit => 50
      
      t.timestamps
    end
  end
end
