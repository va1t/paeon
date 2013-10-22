class AddtoUser < ActiveRecord::Migration
  def up
    add_column :users, :perm,               :boolean, :default => false
    add_column :users, :ability_invoice,    :boolean, :default => false
    add_column :users, :ability_admin,      :boolean, :default => false
    add_column :users, :ability_superadmin, :boolean, :default => false
    add_column :users, :deleted,            :boolean, :default => false
  end

  def down
    remove_column :users, :perm
    remove_column :users, :ability_invoice
    remove_column :users, :ability_admin
    remove_column :users, :ability_superadmin
    remove_column :users, :deleted
  end
end
