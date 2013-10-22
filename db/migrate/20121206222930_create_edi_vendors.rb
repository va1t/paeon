class CreateEdiVendors < ActiveRecord::Migration
  def change
    create_table :edi_vendors do |t|
      t.boolean :primary,          :default => false
      t.string  :name,             :limit => 100
      t.boolean :trans835,         :default => true
      t.boolean :trans837p,        :default => true
      t.boolean :trans837i,        :default => false
      t.boolean :trans837d,        :default => false
      t.boolean :trans997,         :default => false
      t.boolean :trans999,         :default => true
      t.string  :ftp_address,      :limit => 100
      t.integer :ftp_port,         :default => 22
      t.boolean :ssh_sftp_enabled,      :default => true
      t.boolean :passive_mode_enabled,  :default => true
      t.string  :folder_send_to,        :limit => 150, :default => "/inbound"
      t.string  :folder_receive_from,   :limit => 150, :default => "/outbound"
      t.string  :password
      t.string  :username,        :limit => 100
      t.boolean :testing,         :default => true

      t.string  :created_user,    :null => false
      t.string  :updated_user
      t.boolean :deleted,         :null => false, :default => false
      
      t.timestamps
    end
  end
end
