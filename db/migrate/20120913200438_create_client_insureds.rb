class CreateClientInsureds < ActiveRecord::Migration
  def change
    create_table :client_insureds do |t|
      t.references :client,            :null => false
      t.references :insurance_company, :null => false      
      t.string   :ins_policy,                       :limit => 50
      t.string   :ins_group,                        :limit => 50
      t.string   :ins_priority,                     :limit => 50,  :defalut => 'Primary'
      t.string   :type_client,                      :limit => 25,  :default => 'Self'
      t.string   :type_client_other_description,    :limit => 100
      t.string   :type_insurance,                   :limit => 50,  :default => 'Group'
      t.string   :type_insurance_other_description, :limit => 100
      t.boolean  :managed_care,                                    :default => false
      t.datetime :start_date
            
      t.string   :subscriber_first_name,             :limit => 40
      t.string   :subscriber_last_name,              :limit => 40
      t.datetime :subscriber_dob
      t.string   :subscriber_gender,                 :limit => 10
      t.string   :subscriber_address1,               :limit => 40
      t.string   :subscriber_address2,               :limit => 40
      t.string   :subscriber_city,                   :limit => 20
      t.string   :subscriber_state,                  :limit => 15
      t.string   :subscriber_zip,                    :limit => 15
      t.string   :subscriber_ssn_number,             :limit => 20
      
      t.string   :employer_name,                     :limit => 100
      t.string   :employer_address1,                 :limit => 40
      t.string   :employer_address2,                 :limit => 40
      t.string   :employer_city,                     :limit => 20
      t.string   :employer_state,                    :limit => 15
      t.string   :employer_zip,                      :limit => 15
      t.string   :employer_phone,                    :limit => 20    
      t.boolean  :same_address_client,                             :default => false
      t.boolean  :same_as_client,                                  :default => false

      t.string   :created_user,      :null => false
      t.string   :updated_user
      t.boolean  :deleted,           :null => false,               :default => false
      
      t.timestamps
    end
  end
end
