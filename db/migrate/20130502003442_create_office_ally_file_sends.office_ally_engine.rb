# This migration comes from office_ally_engine (originally 20130308020308)
class CreateOfficeAllyFileSends < ActiveRecord::Migration
  def change
    create_table :office_ally_file_sends do |t|
      t.string    :filename,      :limit => 50
      t.integer   :filesize      
      t.string    :sftp_address,  :limit => 100
      t.boolean   :confirmed_sent, :default => false
      t.datetime  :file_sent
      
      t.string    :isa_control_number,  :limit => 10
      t.string    :isa_control_version_number, :limit => 10
      t.string    :gs_control_number, :limit => 10
      t.string    :gs_version_identifier_code, :limit => 15
      t.string    :transaction_set_identifier, :limit => 5
      t.string    :transaction_set_control_number, :limit => 10
      t.integer   :transaction_set_count
      t.integer   :transaction_set_segment_count
      
      t.timestamps
    end
  end
end
