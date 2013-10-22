# This migration comes from office_ally_engine (originally 20130429015420)
class CreateOfficeAlly837ps < ActiveRecord::Migration
  def change
    create_table :office_ally837ps do |t|
      t.references :office_ally_file_send
      
      t.string     :clp_claim_number, :limit => 50
      t.string     :payor_name, :limit => 100
      t.string     :payor_identifier, :limit => 20

      t.timestamps
    end
  end
end
