class AddnameToUsers < ActiveRecord::Migration
  def up
    add_column :users, :login_name, :string
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :home_phone, :string
    add_column :users, :cell_phone, :string
    add_column :users, :created_user, :string
    add_column :users, :updated_user, :string
  end
  

  def down
    remove_column :users, :login_name, :string
    remove_column :users, :first_name, :string
    remove_column :users, :last_name, :string
    remove_column :users, :home_phone, :string
    remove_column :users, :cell_phone, :string
    remove_column :users, :created_user, :string    
    remove_column :users, :updated_user, :string
  end
  
end
