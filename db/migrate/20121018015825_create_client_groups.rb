class CreateClientGroups < ActiveRecord::Migration
  def change
    create_table :client_groups do |t|
      t.references :client
      t.references :group_therapist
      t.string     :client_account_number
      t.decimal    :special_rate,   :precision => 15, :scale => 2
      t.string     :created_user
      t.string     :updated_user
      t.boolean    :deleted,        :default => false

      t.timestamps
    end
    add_index :client_groups, :client_id
    add_index :client_groups, :group_therapist_id
  end
end
