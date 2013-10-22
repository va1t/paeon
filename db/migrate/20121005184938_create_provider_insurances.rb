class CreateProviderInsurances < ActiveRecord::Migration
  def change
    create_table :provider_insurances do |t|
      t.references :providerable, :polymorphic => true
      t.references :insurance_company, :null => false
      t.string     :provider_id,                      :limit => 75
      t.datetime   :expiration_date
      t.datetime   :notification_date
      t.string     :created_user,      :null => false
      t.string     :updated_user
      t.boolean    :deleted,           :null => false, :default => false
      t.datetime   :effective_date
      t.text       :notes
      t.string     :ein_suffix,        :limit => 2
      
      t.timestamps
    end
    add_index :provider_insurances,  [:providerable_type, :providerable_id], :name => "provider_insurances on_providerable"
    add_index :provider_insurances, :insurance_company_id
  end
end
