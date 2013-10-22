# This migration comes from office_ally_engine (originally 20130711161834)
class CreateOfficeAlly999Errors < ActiveRecord::Migration
  def change
    create_table :office_ally999_errors do |t|
      t.references :office_ally999
      t.string     :segment,          :limit => 10   
      t.integer    :segment_position
      t.string     :loop,             :limit => 10
      t.string     :error_code,       :limit => 10

      t.timestamps
    end
    add_index :office_ally999_errors, :office_ally999_id
  end
end
