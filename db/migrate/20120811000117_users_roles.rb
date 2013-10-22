class UsersRoles < ActiveRecord::Migration
  def up
    create_table :roles_users, :id => false do |t|
      t.references :role,     :null => false
      t.references :user,     :null => false
    end
  end

  def down
    drop_table :roles_users
  end
end
