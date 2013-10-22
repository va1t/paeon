class CreateClientTherapists < ActiveRecord::Migration
  def change
    create_table :client_therapists do |t|
      t.references :client
      t.references :therapist
      t.string     :client_account_number
      t.decimal    :special_rate, :precision => 15, :scale => 2
      t.string     :created_user
      t.string     :updated_user
      t.boolean    :deleted,      :default => false

      t.timestamps
    end
    add_index :client_therapists, :client_id
    add_index :client_therapists, :therapist_id
  end
end
