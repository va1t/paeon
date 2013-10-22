class CreateSubscriberValidations < ActiveRecord::Migration
  def change
    create_table :subscriber_valids do |t|
      t.references :validable,  :polymorphic => true
      t.references :subscriber
      t.integer    :in_network,   :default => 0      
      t.datetime   :validated_date
      
      t.string     :created_user, :null => false
      t.string     :updated_user
      t.boolean    :deleted,      :null => false, :default => false

      t.timestamps
    end
    
    add_index :subscriber_valids, [:validable_type, :validable_id]
    add_index :subscriber_valids, :subscriber_id
  end
end
