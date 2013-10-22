# This migration comes from office_ally_engine (originally 20130308023840)
class CreateOfficeAllyFileReceives < ActiveRecord::Migration
  def change
    create_table :office_ally_file_receives do |t|
      t.string    :filename,      :limit => 50
      t.integer   :size
      t.string    :extension,     :limit => 50
      t.boolean   :was_zipped,    :default => false
      t.string    :zipfile_name,  :limit => 75
      
      t.datetime  :file_downloaded
      t.datetime  :file_parsed
      t.datetime  :file_purged
      t.datetime  :file_modified
      t.datetime  :file_accessed

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
