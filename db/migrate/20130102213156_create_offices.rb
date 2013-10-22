class CreateOffices < ActiveRecord::Migration
  def change
    create_table :offices do |t|
      t.references :officeable, :polymorphic => true
      t.string     :priority,        :limit => 40
      t.string     :address1,        :limit => 40 
      t.string     :address2,        :limit => 40
      t.string     :city,            :limit => 20
      t.string     :state,           :limit => 15
      t.string     :zip,             :limit => 15
      t.string     :office_phone,    :limit => 20
      t.string     :office_fax,      :limit => 20 
      t.string     :second_phone,    :limit => 20     
      t.string     :third_phone,     :limit => 20      
      t.string     :office_name,     :limit => 50
      t.boolean    :billing_location, :default => false
      t.string     :created_user,    :null => false
      t.string     :updated_user
      t.boolean    :deleted,         :null => false, :default => false

      t.timestamps
    end
    
    add_index :offices, [:officeable_type, :officeable_id]
    
  end
end
